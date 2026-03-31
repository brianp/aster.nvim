/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

const PREC = {
  LAMBDA: 1,
  OR: 2,
  AND: 3,
  EQUALITY: 4,
  COMPARISON: 5,
  RANGE: 6,
  ADDITIVE: 7,
  MULTIPLICATIVE: 8,
  EXPONENT: 9,
  UNARY: 10,
  POSTFIX: 11,
  CALL: 12,
};

module.exports = grammar({
  name: "aster",

  externals: ($) => [$._indent, $._dedent, $._newline],

  extras: ($) => [/[ \t\r]/, $.comment],

  word: ($) => $.identifier,

  conflicts: ($) => [
    [$.method_call_expression, $.member_expression],
  ],

  rules: {
    source_file: ($) =>
      repeat($._toplevel_item),

    _toplevel_item: ($) =>
      choice(
        $._compound_statement,
        seq($._simple_statement, $._newline),
        $._newline,
      ),

    _compound_statement: ($) =>
      choice(
        $.function_definition,
        $.class_definition,
        $.trait_definition,
        $.enum_definition,
        $.if_statement,
        $.while_statement,
        $.for_statement,
        $.match_statement,
      ),

    _simple_statement: ($) =>
      choice(
        $.let_binding,
        $.const_binding,
        $.use_statement,
        $.return_statement,
        $.break_statement,
        $.continue_statement,
        $.throw_statement,
        $.assignment,
        $.expression_statement,
      ),

    expression_statement: ($) => $.expression,

    // ─── Definitions ────────────────────────────────────────────

    function_definition: ($) =>
      seq(
        optional($.visibility),
        optional("async"),
        "def",
        field("name", $.identifier),
        optional($.type_parameters),
        $.parameter_list,
        optional($.throws_clause),
        optional(seq("->", field("return_type", $.type))),
        $._newline,
        field("body", $.block),
      ),

    class_definition: ($) =>
      seq(
        optional($.visibility),
        "class",
        field("name", $.identifier),
        optional($.type_parameters),
        optional(seq("extends", field("superclass", $.type))),
        optional($.includes_clause),
        $._newline,
        field("body", $.class_body),
      ),

    class_body: ($) =>
      seq(
        $._indent,
        repeat1(
          choice(
            $.field_declaration,
            $.function_definition,
            $._newline,
          ),
        ),
        $._dedent,
      ),

    field_declaration: ($) =>
      seq(
        optional($.visibility),
        field("name", $.identifier),
        ":",
        field("type", $.type),
        $._newline,
      ),

    trait_definition: ($) =>
      seq(
        optional($.visibility),
        "trait",
        field("name", $.identifier),
        optional($.type_parameters),
        $._newline,
        field("body", $.trait_body),
      ),

    trait_body: ($) =>
      seq(
        $._indent,
        repeat1(
          choice(
            $.function_definition,
            $.trait_method_signature,
            $._newline,
          ),
        ),
        $._dedent,
      ),

    trait_method_signature: ($) =>
      seq(
        optional($.visibility),
        optional("async"),
        "def",
        field("name", $.identifier),
        $.parameter_list,
        optional($.throws_clause),
        optional(seq("->", field("return_type", $.type))),
        $._newline,
      ),

    enum_definition: ($) =>
      seq(
        optional($.visibility),
        "enum",
        field("name", $.identifier),
        optional($.type_parameters),
        optional($.includes_clause),
        $._newline,
        field("body", $.enum_body),
      ),

    enum_body: ($) =>
      seq(
        $._indent,
        repeat1(
          choice(
            $.enum_variant,
            $.function_definition,
            $._newline,
          ),
        ),
        $._dedent,
      ),

    enum_variant: ($) =>
      seq(
        field("name", $.identifier),
        optional($.variant_parameters),
        $._newline,
      ),

    variant_parameters: ($) =>
      seq(
        "(",
        commaSep1(seq(field("name", $.identifier), ":", field("type", $.type))),
        ")",
      ),

    // ─── Common definition parts ────────────────────────────────

    visibility: (_) => "pub",

    type_parameters: ($) =>
      seq("[", commaSep1($.identifier), "]"),

    parameter_list: ($) =>
      seq("(", commaSep($.parameter), ")"),

    parameter: ($) =>
      seq(
        field("name", $.identifier),
        ":",
        field("type", $.type),
        optional(seq("=", field("default", $.expression))),
      ),

    throws_clause: ($) =>
      seq("throws", field("error_type", $.type)),

    includes_clause: ($) =>
      seq("includes", commaSep1($.type)),

    // ─── Types ──────────────────────────────────────────────────

    type: ($) =>
      prec.left(seq($._type_inner, optional("?"))),

    _type_inner: ($) =>
      choice(
        $.builtin_type,
        $.generic_type,
        $.function_type,
        $.type_identifier,
      ),

    builtin_type: (_) =>
      choice("Int", "Float", "Bool", "String", "Void", "Nil", "Never"),

    type_identifier: ($) => alias($.identifier, $.type_identifier),

    generic_type: ($) =>
      prec(1, seq(
        field("name", $.identifier),
        "[",
        commaSep1($.type),
        "]",
      )),

    function_type: ($) =>
      seq(
        "Fn",
        "(",
        commaSep($.type),
        ")",
        "->",
        $.type,
      ),

    // ─── Control flow ───────────────────────────────────────────

    if_statement: ($) =>
      seq(
        "if",
        field("condition", $.expression),
        $._newline,
        field("then", $.block),
        repeat($.elif_clause),
        optional($.else_clause),
      ),

    elif_clause: ($) =>
      seq(
        "elif",
        field("condition", $.expression),
        $._newline,
        field("body", $.block),
      ),

    else_clause: ($) =>
      seq(
        "else",
        $._newline,
        field("body", $.block),
      ),

    while_statement: ($) =>
      seq(
        "while",
        field("condition", $.expression),
        $._newline,
        field("body", $.block),
      ),

    for_statement: ($) =>
      seq(
        "for",
        field("variable", $.identifier),
        "in",
        field("iterable", $.expression),
        $._newline,
        field("body", $.block),
      ),

    match_statement: ($) =>
      seq(
        "match",
        field("scrutinee", $.expression),
        $._newline,
        field("body", $.match_body),
      ),

    match_body: ($) =>
      seq(
        $._indent,
        repeat1($.match_arm),
        $._dedent,
      ),

    match_arm: ($) =>
      seq(
        field("pattern", $.pattern),
        "=>",
        field("value", $.expression),
        $._newline,
      ),

    pattern: ($) =>
      choice(
        $.wildcard_pattern,
        $.literal_pattern,
        $.enum_pattern,
        $.identifier,
      ),

    wildcard_pattern: (_) => "_",

    literal_pattern: ($) =>
      choice(
        $.integer,
        $.float,
        $.string,
        $.true,
        $.false,
        $.nil,
        seq("-", $.integer),
        seq("-", $.float),
      ),

    enum_pattern: ($) =>
      seq(
        field("type", $.identifier),
        ".",
        field("variant", $.identifier),
      ),

    // ─── Simple statements ──────────────────────────────────────

    let_binding: ($) =>
      seq(
        optional($.visibility),
        "let",
        field("name", $.identifier),
        optional(seq(":", field("type", $.type))),
        "=",
        field("value", $.expression),
      ),

    const_binding: ($) =>
      seq(
        optional($.visibility),
        "const",
        field("name", $.identifier),
        optional(seq(":", field("type", $.type))),
        "=",
        field("value", $.expression),
      ),

    use_statement: ($) =>
      seq(
        optional($.visibility),
        "use",
        field("path", $.module_path),
        optional($.import_list),
      ),

    module_path: ($) =>
      seq($.identifier, repeat(seq("/", $.identifier))),

    import_list: ($) =>
      seq(
        "{",
        commaSep1(
          choice(
            seq($.identifier, "as", $.identifier),
            $.identifier,
          ),
        ),
        "}",
      ),

    return_statement: ($) =>
      prec.right(seq("return", optional($.expression))),

    break_statement: (_) => "break",

    continue_statement: (_) => "continue",

    throw_statement: ($) =>
      seq("throw", $.expression),

    assignment: ($) =>
      prec.right(-1, seq(
        field("target", $.expression),
        "=",
        field("value", $.expression),
      )),

    // ─── Expressions ────────────────────────────────────────────

    expression: ($) =>
      choice(
        $.binary_expression,
        $.unary_expression,
        $.call_expression,
        $.method_call_expression,
        $.index_expression,
        $.member_expression,
        $.async_expression,
        $.blocking_expression,
        $.detached_expression,
        $.resolve_expression,
        $.error_propagation,
        $.lambda,
        $.primary_expression,
      ),

    primary_expression: ($) =>
      choice(
        $.identifier,
        $.integer,
        $.float,
        $.string,
        $.true,
        $.false,
        $.nil,
        $.list_literal,
        $.map_literal,
        $.parenthesized_expression,
      ),

    parenthesized_expression: ($) =>
      seq("(", $.expression, ")"),

    binary_expression: ($) =>
      choice(
        prec.left(PREC.OR, seq($.expression, "or", $.expression)),
        prec.left(PREC.AND, seq($.expression, "and", $.expression)),
        prec.left(PREC.EQUALITY, seq($.expression, choice("==", "!="), $.expression)),
        prec.left(PREC.COMPARISON, seq($.expression, choice("<", ">", "<=", ">="), $.expression)),
        prec.left(PREC.RANGE, seq($.expression, choice("..", "..="), $.expression)),
        prec.left(PREC.ADDITIVE, seq($.expression, choice("+", "-"), $.expression)),
        prec.left(PREC.MULTIPLICATIVE, seq($.expression, choice("*", "/", "%"), $.expression)),
        prec.right(PREC.EXPONENT, seq($.expression, "**", $.expression)),
      ),

    unary_expression: ($) =>
      prec(PREC.UNARY, seq(choice("-", "not"), $.expression)),

    call_expression: ($) =>
      prec(PREC.CALL, seq(
        field("function", $.expression),
        $.argument_list,
      )),

    method_call_expression: ($) =>
      prec(PREC.POSTFIX, seq(
        field("object", $.expression),
        ".",
        field("method", $.identifier),
        $.argument_list,
      )),

    index_expression: ($) =>
      prec(PREC.POSTFIX, seq(
        field("object", $.expression),
        "[",
        field("index", $.expression),
        "]",
      )),

    member_expression: ($) =>
      prec(PREC.POSTFIX, seq(
        field("object", $.expression),
        ".",
        field("field", $.identifier),
      )),

    argument_list: ($) =>
      seq("(", commaSep($.argument), ")"),

    argument: ($) =>
      choice(
        seq(field("name", $.identifier), ":", field("value", $.expression)),
        $.expression,
      ),

    async_expression: ($) =>
      prec(PREC.UNARY, seq("async", $.expression)),

    blocking_expression: ($) =>
      prec(PREC.UNARY, seq("blocking", $.expression)),

    detached_expression: ($) =>
      prec(PREC.UNARY, seq("detached", "async", $.expression)),

    resolve_expression: ($) =>
      prec(PREC.UNARY, seq("resolve", $.expression)),

    error_propagation: ($) =>
      prec(PREC.POSTFIX, seq($.expression, "!")),

    lambda: ($) =>
      prec.right(PREC.LAMBDA, seq(
        "->",
        optional(commaSep1($.identifier)),
        ":",
        $.expression,
      )),

    // ─── Collection literals ────────────────────────────────────

    list_literal: ($) =>
      seq("[", commaSep($.expression), "]"),

    map_literal: ($) =>
      seq("{", commaSep($.map_entry), "}"),

    map_entry: ($) =>
      seq(field("key", $.expression), ":", field("value", $.expression)),

    // ─── Blocks ─────────────────────────────────────────────────

    block: ($) =>
      seq(
        $._indent,
        repeat1($._block_item),
        $._dedent,
      ),

    _block_item: ($) =>
      choice(
        $._compound_statement,
        seq($._simple_statement, $._newline),
        $._newline,
      ),

    // ─── Literals ───────────────────────────────────────────────

    integer: (_) => /\d+/,

    float: (_) => /\d+\.\d+/,

    string: ($) =>
      choice(
        $._simple_string,
        $.interpolated_string,
      ),

    _simple_string: (_) =>
      token(seq('"', /[^"\\{]*(\\.[^"\\{]*)*/, '"')),

    interpolated_string: ($) =>
      seq(
        $.string_start,
        repeat(seq($.interpolation, optional($.string_middle))),
        $.string_end,
      ),

    string_start: (_) => token(seq('"', /[^"\\{]*(\\.[^"\\{]*)*/, "{")),
    string_middle: (_) => token(seq("}", /[^"\\{]*(\\.[^"\\{]*)*/, "{")),
    string_end: (_) => token(seq("}", /[^"\\{]*(\\.[^"\\{]*)*/, '"')),

    interpolation: ($) => $.expression,

    true: (_) => "true",
    false: (_) => "false",
    nil: (_) => "nil",

    identifier: (_) => /[a-zA-Z_][a-zA-Z0-9_]*/,

    comment: (_) => token(seq("#", /.*/)),
  },
});

function commaSep1(rule) {
  return seq(rule, repeat(seq(",", rule)), optional(","));
}

function commaSep(rule) {
  return optional(commaSep1(rule));
}
