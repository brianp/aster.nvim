; ─── Keywords ────────────────────────────────────────────────────────

[
  "def"
  "class"
  "trait"
  "enum"
  "includes"
  "extends"
] @keyword

[
  "let"
  "const"
] @keyword.storage

[
  "if"
  "elif"
  "else"
  "match"
] @keyword.conditional

[
  "for"
  "while"
  "break"
  "continue"
  "in"
] @keyword.repeat

[
  "return"
  "throw"
] @keyword.return

[
  "use"
  "as"
] @keyword.import

[
  "async"
  "blocking"
  "detached"
  "resolve"
] @keyword.coroutine

"pub" @keyword.modifier

"throws" @keyword.exception

(throw_expression
  "throw" @keyword.exception)

; ─── Functions ───────────────────────────────────────────────────────

(function_definition
  name: (identifier) @function)

(trait_method_signature
  name: (identifier) @function)

(call_expression
  function: (expression
    (primary_expression
      (identifier) @function.call)))

(method_call_expression
  method: (identifier) @function.method.call)

; ─── Types ───────────────────────────────────────────────────────────

(builtin_type) @type.builtin

(type_identifier) @type

(generic_type
  name: (identifier) @type)

(class_definition
  name: (identifier) @type.definition)

(trait_definition
  name: (identifier) @type.definition)

(enum_definition
  name: (identifier) @type.definition)

(enum_variant
  name: (identifier) @constant)

(enum_pattern
  type: (identifier) @type
  variant: (identifier) @constant)

; ─── Variables and parameters ────────────────────────────────────────

(parameter
  name: (identifier) @variable.parameter)

(let_binding
  name: (identifier) @variable)

(const_binding
  name: (identifier) @constant)

(field_declaration
  name: (identifier) @variable.member)

(member_expression
  field: (identifier) @variable.member)

(argument
  name: (identifier) @variable.parameter)

(for_statement
  variable: (identifier) @variable)

; ─── Literals ────────────────────────────────────────────────────────

(integer) @number

(float) @number.float

(string) @string
(interpolated_string) @string
(string_start) @string
(string_middle) @string
(string_end) @string

(true) @boolean
(false) @boolean
(nil) @constant.builtin

; ─── Operators ───────────────────────────────────────────────────────

[
  "+"
  "-"
  "*"
  "/"
  "%"
  "**"
] @operator

[
  "=="
  "!="
  "<"
  ">"
  "<="
  ">="
] @operator

[
  "and"
  "or"
  "not"
] @keyword.operator

[
  ".."
  "..="
] @operator

[
  "="
  "=>"
  "->"
  "!"
] @operator

; ─── Punctuation ─────────────────────────────────────────────────────

["(" ")"] @punctuation.bracket
["[" "]"] @punctuation.bracket
["{" "}"] @punctuation.bracket

[
  ","
  "."
  ":"
  "/"
] @punctuation.delimiter

"?" @punctuation.special

; ─── Comments ────────────────────────────────────────────────────────

(comment) @comment @spell

; ─── Patterns ────────────────────────────────────────────────────────

(wildcard_pattern) @variable.builtin

(match_expression
  "match" @keyword.conditional)

; ─── Module paths ────────────────────────────────────────────────────

(module_path
  (identifier) @module)

(import_list
  (identifier) @type)
