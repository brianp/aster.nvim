#include "tree_sitter/parser.h"
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

enum TokenType {
  INDENT,
  DEDENT,
  NEWLINE,
};

#define MAX_DEPTH 100

typedef struct {
  uint32_t indent_length_stack[MAX_DEPTH];
  uint32_t stack_size;
  uint32_t queued_dedent_count;
} Scanner;

void *tree_sitter_aster_external_scanner_create(void) {
  Scanner *s = calloc(1, sizeof(Scanner));
  s->indent_length_stack[0] = 0;
  s->stack_size = 1;
  s->queued_dedent_count = 0;
  return s;
}

void tree_sitter_aster_external_scanner_destroy(void *payload) {
  free(payload);
}

unsigned tree_sitter_aster_external_scanner_serialize(void *payload, char *buffer) {
  Scanner *s = (Scanner *)payload;
  unsigned n = 0;
  buffer[n++] = s->queued_dedent_count;
  buffer[n++] = s->stack_size;
  for (uint32_t i = 0; i < s->stack_size && n + 2 <= TREE_SITTER_SERIALIZATION_BUFFER_SIZE; i++) {
    buffer[n++] = s->indent_length_stack[i] & 0xff;
    buffer[n++] = (s->indent_length_stack[i] >> 8) & 0xff;
  }
  return n;
}

void tree_sitter_aster_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
  Scanner *s = (Scanner *)payload;
  s->indent_length_stack[0] = 0;
  s->stack_size = 1;
  s->queued_dedent_count = 0;
  if (length == 0) return;
  unsigned n = 0;
  s->queued_dedent_count = (uint8_t)buffer[n++];
  if (n >= length) return;
  s->stack_size = (uint8_t)buffer[n++];
  for (uint32_t i = 0; i < s->stack_size && n + 1 < length; i++) {
    s->indent_length_stack[i] = (uint8_t)buffer[n] | ((uint8_t)buffer[n + 1] << 8);
    n += 2;
  }
}

static uint32_t measure_indent(TSLexer *lexer) {
  uint32_t indent = 0;
  while (lexer->lookahead == ' ' || lexer->lookahead == '\t') {
    if (lexer->lookahead == '\t') indent += 2; else indent++;
    lexer->advance(lexer, true);
  }
  return indent;
}

bool tree_sitter_aster_external_scanner_scan(void *payload, TSLexer *lexer,
                                              const bool *valid_symbols) {
  Scanner *s = (Scanner *)payload;

  // 1. Emit queued dedents
  if (s->queued_dedent_count > 0 && valid_symbols[DEDENT]) {
    s->queued_dedent_count--;
    lexer->result_symbol = DEDENT;
    return true;
  }

  // 2. At column 0 and INDENT/DEDENT is valid: measure indent
  if (lexer->get_column(lexer) == 0 && (valid_symbols[INDENT] || valid_symbols[DEDENT])) {
    uint32_t indent = measure_indent(lexer);
    uint32_t current = s->indent_length_stack[s->stack_size - 1];

    // Skip blank lines: if after measuring indent we see \n, it's a blank line
    // Consume it and re-measure
    while ((lexer->lookahead == '\n' || lexer->lookahead == '\r') && !lexer->eof(lexer)) {
      lexer->advance(lexer, true);
      indent = measure_indent(lexer);
    }

    // Skip comment-only lines
    while (lexer->lookahead == '#' && !lexer->eof(lexer)) {
      while (lexer->lookahead != '\n' && !lexer->eof(lexer)) {
        lexer->advance(lexer, true);
      }
      if (lexer->lookahead == '\n') {
        lexer->advance(lexer, true);
      }
      indent = measure_indent(lexer);
      // Another blank line?
      while ((lexer->lookahead == '\n' || lexer->lookahead == '\r') && !lexer->eof(lexer)) {
        lexer->advance(lexer, true);
        indent = measure_indent(lexer);
      }
    }

    if (lexer->eof(lexer)) {
      if (valid_symbols[DEDENT] && s->stack_size > 1) {
        s->stack_size--;
        lexer->result_symbol = DEDENT;
        return true;
      }
      return false;
    }

    if (indent > current && valid_symbols[INDENT]) {
      if (s->stack_size < MAX_DEPTH) {
        s->indent_length_stack[s->stack_size++] = indent;
      }
      lexer->result_symbol = INDENT;
      return true;
    }

    if (indent < current && valid_symbols[DEDENT]) {
      uint32_t dedents = 0;
      while (s->stack_size > 1 && s->indent_length_stack[s->stack_size - 1] > indent) {
        s->stack_size--;
        dedents++;
      }
      if (dedents > 1) {
        s->queued_dedent_count = dedents - 1;
      }
      lexer->result_symbol = DEDENT;
      return true;
    }

    // Same indent: no INDENT/DEDENT needed
    // Fall through to NEWLINE handling
  }

  // 3. NEWLINE production
  if (!valid_symbols[NEWLINE]) {
    return false;
  }

  // At EOF with indented blocks still open
  if (lexer->eof(lexer)) {
    if (s->stack_size > 1) {
      lexer->result_symbol = NEWLINE;
      return true;
    }
    return false;
  }

  // Skip horizontal whitespace before checking for newline
  while (lexer->lookahead == ' ' || lexer->lookahead == '\t' || lexer->lookahead == '\r') {
    lexer->advance(lexer, true);
  }

  if (lexer->lookahead != '\n') {
    return false;
  }

  // Consume the newline character
  lexer->advance(lexer, true);

  // DON'T consume anything else. Let the next call handle indent measurement.
  lexer->result_symbol = NEWLINE;
  return true;
}
