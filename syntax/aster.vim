" Vim syntax file for the Aster programming language
" Language: Aster
" Maintainer: aster-lang contributors

if exists("b:current_syntax")
  finish
endif

" ─── Keywords ────────────────────────────────────────────────────────

syn keyword asterKeyword        def class trait enum includes extends
syn keyword asterStorage        let const
syn keyword asterConditional    if elif else match
syn keyword asterRepeat         for while break continue in
syn keyword asterReturn         return throw
syn keyword asterImport         use as
syn keyword asterAsync          async blocking detached resolve
syn keyword asterModifier       pub
syn keyword asterException      throws catch

" ─── Operators ───────────────────────────────────────────────────────

syn keyword asterOperatorWord   and or not
syn match   asterOperator       /+/
syn match   asterOperator       /-/
syn match   asterOperator       /\*/
syn match   asterOperator       /\//
syn match   asterOperator       /%/
syn match   asterOperator       /\*\*/
syn match   asterOperator       /==/
syn match   asterOperator       /!=/
syn match   asterOperator       /<=/
syn match   asterOperator       />=/
syn match   asterOperator       /</
syn match   asterOperator       />/
syn match   asterOperator       /=>/
syn match   asterOperator       /->/
syn match   asterOperator       /\.\./
syn match   asterOperator       /\.\.=/
syn match   asterOperator       /!/

" ─── Types ───────────────────────────────────────────────────────────

syn keyword asterBuiltinType    Int Float Bool String Void Nil Never
syn keyword asterBuiltinType    List Map Set Task Fn
syn match   asterType           /\<[A-Z][a-zA-Z0-9_]*\>/

" ─── Literals ────────────────────────────────────────────────────────

syn keyword asterBoolean        true false
syn keyword asterNil            nil

syn match   asterFloat          /\<\d\+\.\d\+\>/
syn match   asterInteger        /\<\d\+\>/

" ─── Strings with interpolation ──────────────────────────────────────

syn region  asterString         start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=asterStringEscape,asterStringInterp
syn match   asterStringEscape   /\\[ntr0\\"{}]/ contained
syn region  asterStringInterp   start=/{/ end=/}/ contained contains=TOP

" ─── Comments ────────────────────────────────────────────────────────

syn match   asterComment        /#.*$/ contains=asterTodo
syn keyword asterTodo           TODO FIXME NOTE XXX HACK BUG contained

" ─── Functions ───────────────────────────────────────────────────────

syn match   asterFuncDef        /\<def\s\+\zs[a-zA-Z_][a-zA-Z0-9_]*/
syn match   asterFuncCall       /\<[a-zA-Z_][a-zA-Z0-9_]*\ze\s*(/

" ─── Special ─────────────────────────────────────────────────────────

syn match   asterWildcard       /\<_\>/

" ─── Highlighting links ─────────────────────────────────────────────

hi def link asterKeyword        Keyword
hi def link asterStorage        StorageClass
hi def link asterConditional    Conditional
hi def link asterRepeat         Repeat
hi def link asterReturn         Statement
hi def link asterImport         Include
hi def link asterAsync          Keyword
hi def link asterModifier       StorageClass
hi def link asterException      Exception
hi def link asterOperatorWord   Keyword
hi def link asterOperator       Operator
hi def link asterBuiltinType    Type
hi def link asterType           Type
hi def link asterBoolean        Boolean
hi def link asterNil            Constant
hi def link asterFloat          Float
hi def link asterInteger        Number
hi def link asterString         String
hi def link asterStringEscape   SpecialChar
hi def link asterStringInterp   Special
hi def link asterComment        Comment
hi def link asterTodo           Todo
hi def link asterFuncDef        Function
hi def link asterFuncCall       Function
hi def link asterWildcard       Special

let b:current_syntax = "aster"
