" Vim syntax file for the Aster programming language
" Language: Aster
" Maintainer: aster-lang contributors

if exists("b:current_syntax")
  finish
endif

" ─── Comments (highest priority) ─────────────────────────────────────

syn match   asterComment        /#.*$/ contains=asterTodo,@Spell
syn keyword asterTodo           TODO FIXME NOTE XXX HACK BUG SAFETY PERF contained

" ─── Strings with interpolation ──────────────────────────────────────

syn region  asterString         start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=asterStringEscape,asterInterpolation,@Spell
syn match   asterStringEscape   /\\[ntr0\\"{}]/ contained
syn region  asterInterpolation  matchgroup=asterInterpDelim start=/{/ end=/}/ contained contains=TOP

" ─── Keywords ────────────────────────────────────────────────────────

syn keyword asterKeyword        def includes extends nextgroup=asterFuncDef,asterTypeDef skipwhite
syn keyword asterStructure      class trait enum nextgroup=asterTypeDef skipwhite
syn keyword asterStorage        let nextgroup=asterVarDef skipwhite
syn keyword asterStorageConst   const nextgroup=asterConstDef skipwhite
syn keyword asterConditional    if elif else match
syn keyword asterRepeat         for while in
syn keyword asterRepeatControl  break continue
syn keyword asterReturn         return
syn keyword asterThrow          throw
syn keyword asterImport         use nextgroup=asterModulePath skipwhite
syn keyword asterImportAs       as
syn keyword asterAsync          async blocking detached resolve
syn keyword asterModifier       pub nextgroup=asterKeyword,asterStructure,asterStorage,asterStorageConst skipwhite
syn keyword asterException      throws catch

" ─── Definitions (highlighted via nextgroup) ─────────────────────────

syn match   asterFuncDef        /[a-zA-Z_][a-zA-Z0-9_]*/ contained
syn match   asterTypeDef        /[A-Z][a-zA-Z0-9_]*/ contained
syn match   asterVarDef         /[a-zA-Z_][a-zA-Z0-9_]*/ contained
syn match   asterConstDef       /[A-Z_][a-zA-Z0-9_]*/ contained

" ─── Module paths (use std/fs { File }) ──────────────────────────────

syn match   asterModulePath     /[a-zA-Z_][a-zA-Z0-9_]*\(\/[a-zA-Z_][a-zA-Z0-9_]*\)*/ contained nextgroup=asterImportBlock skipwhite
syn region  asterImportBlock    start=/{/ end=/}/ contained contains=asterImportName,asterImportAs
syn match   asterImportName     /[A-Z][a-zA-Z0-9_]*/ contained

" ─── Operators ───────────────────────────────────────────────────────

syn keyword asterOperatorWord   and or not

" Arrows and special operators (match before generic operators)
syn match   asterArrow          /->/
syn match   asterFatArrow       /=>/
syn match   asterErrorProp      /!/

" Range operators
syn match   asterRange          /\.\.\=/
syn match   asterRange          /\.\./

" Comparison and equality (match longer first)
syn match   asterOperator       /==/
syn match   asterOperator       /!=/
syn match   asterOperator       /<=/
syn match   asterOperator       />=/
syn match   asterOperator       /</
syn match   asterOperator       />/

" Arithmetic
syn match   asterOperator       /\*\*/
syn match   asterOperator       /[+\-*/%]/

" Assignment (but not ==, =>, !=, <=, >=)
syn match   asterAssign         /\%(=\|!\|<\|>\)\@<!=\%(=\|>\)\@!/

" ─── Types ───────────────────────────────────────────────────────────

syn keyword asterBuiltinType    Int Float Bool String Void Nil Never
syn keyword asterCollectionType List Map Set Task Fn
syn match   asterType           /\<[A-Z][a-zA-Z0-9_]*\>/
syn match   asterNullable       /?/

" ─── Literals ────────────────────────────────────────────────────────

syn keyword asterBoolean        true false
syn keyword asterNil            nil

syn match   asterFloat          /\<\d\+\.\d\+\>/
syn match   asterInteger        /\<\d\+\>/

" ─── Function calls and named parameters ─────────────────────────────

" Named argument: `name:` in function calls
syn match   asterNamedArg       /\<[a-z_][a-zA-Z0-9_]*\ze\s*:/ contained
" Function call: `foo(` including method calls after .
syn match   asterFuncCall       /\<[a-z_][a-zA-Z0-9_]*\ze\s*(/
" Method call: `.method(`
syn match   asterMethodCall     /\.\zs[a-z_][a-zA-Z0-9_]*\ze\s*(/
" Member access: `.field` (not followed by `(`)
syn match   asterMember         /\.\zs[a-z_][a-zA-Z0-9_]*\>\ze\s*[^(]/

" Highlight named args inside parens
syn region  asterArgList        matchgroup=asterParen start=/(/ end=/)/ transparent contains=TOP

" ─── Field declarations (inside class/trait/enum bodies) ─────────────

" `name: Type` at indented level (field declaration pattern)
syn match   asterFieldDecl      /^\s\+\%(pub\s\+\)\?\zs[a-z_][a-zA-Z0-9_]*\ze\s*:\s*[A-Z]/

" ─── Special identifiers ────────────────────────────────────────────

syn keyword asterSelf           self
syn match   asterWildcard       /\<_\>/

" ─── Punctuation ─────────────────────────────────────────────────────

syn match   asterDelimiter      /[,.:]/
syn match   asterBracket        /[(){}\[\]]/

" ─── Highlighting links ─────────────────────────────────────────────

" Keywords
hi def link asterKeyword        Keyword
hi def link asterStructure      Structure
hi def link asterStorage        StorageClass
hi def link asterStorageConst   StorageClass
hi def link asterConditional    Conditional
hi def link asterRepeat         Repeat
hi def link asterRepeatControl  Repeat
hi def link asterReturn         Statement
hi def link asterThrow          Exception
hi def link asterImport         Include
hi def link asterImportAs       Include
hi def link asterAsync          Keyword
hi def link asterModifier       StorageClass
hi def link asterException      Exception

" Definitions
hi def link asterFuncDef        Function
hi def link asterTypeDef        Type
hi def link asterVarDef         Identifier
hi def link asterConstDef       Constant

" Modules and imports
hi def link asterModulePath     Include
hi def link asterImportName     Type

" Operators
hi def link asterOperatorWord   Keyword
hi def link asterOperator       Operator
hi def link asterArrow          Operator
hi def link asterFatArrow       Operator
hi def link asterErrorProp      Operator
hi def link asterRange          Operator
hi def link asterAssign         Operator

" Types
hi def link asterBuiltinType    Type
hi def link asterCollectionType Type
hi def link asterType           Type
hi def link asterNullable       Special

" Literals
hi def link asterBoolean        Boolean
hi def link asterNil            Constant
hi def link asterFloat          Float
hi def link asterInteger        Number

" Strings
hi def link asterString         String
hi def link asterStringEscape   SpecialChar
hi def link asterInterpolation  Special
hi def link asterInterpDelim    Delimiter

" Functions and members
hi def link asterFuncCall       Function
hi def link asterMethodCall     Function
hi def link asterMember         Identifier
hi def link asterNamedArg       Label
hi def link asterFieldDecl      Identifier

" Special
hi def link asterSelf           Constant
hi def link asterWildcard       Special
hi def link asterComment        Comment
hi def link asterTodo           Todo
hi def link asterDelimiter      Delimiter
hi def link asterBracket        Delimiter

let b:current_syntax = "aster"
