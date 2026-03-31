; Scopes
(function_definition) @local.scope
(class_definition) @local.scope
(trait_definition) @local.scope
(block) @local.scope
(for_statement) @local.scope

; Definitions
(function_definition
  name: (identifier) @local.definition.function)

(parameter
  name: (identifier) @local.definition.parameter)

(let_binding
  name: (identifier) @local.definition.var)

(const_binding
  name: (identifier) @local.definition.var)

(for_statement
  variable: (identifier) @local.definition.var)

(class_definition
  name: (identifier) @local.definition.type)

(trait_definition
  name: (identifier) @local.definition.type)

(enum_definition
  name: (identifier) @local.definition.type)

(field_declaration
  name: (identifier) @local.definition.field)

; References
(identifier) @local.reference
