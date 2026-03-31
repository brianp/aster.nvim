# aster.nvim

Neovim plugin for the [Aster](https://github.com/your-org/asterc) programming language.

## Features

- Syntax highlighting (tree-sitter and vim syntax fallback)
- Indentation support for Aster's Python-like block structure
- Comment toggling (`gc` with Comment.nvim, etc.)
- Code folding
- Local variable tracking (tree-sitter locals)
- LSP client configuration (for when `aster-lsp` ships)

## Installation

### lazy.nvim

```lua
{
  "your-org/aster.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  ft = "aster",
  opts = {},
}
```

### Manual / Development

Clone the repo and add to your lazy.nvim config:

```lua
{
  dir = "~/Projects/aster.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  ft = "aster",
  opts = {},
}
```

## Setup

Call `setup()` in your config (lazy.nvim does this automatically with `opts = {}`):

```lua
require("aster").setup({
  -- Tree-sitter integration (default: true)
  treesitter = true,

  -- LSP configuration (disabled by default, enable when aster-lsp is available)
  -- lsp = {
  --   cmd = { "aster-lsp" },
  -- },
})
```

## Tree-sitter Grammar

The tree-sitter grammar lives in `tree-sitter-aster/` within this plugin. After installing the plugin, install the parser:

```vim
:TSInstall aster
```

Or from the CLI:

```bash
cd tree-sitter-aster
npm install
npx tree-sitter generate
```

## Syntax Highlighting Without Tree-sitter

The plugin includes a vim syntax file (`syntax/aster.vim`) that provides highlighting without tree-sitter. It activates automatically if tree-sitter parsing is not available for Aster files.

## File Detection

Any file with a `.aster` extension is automatically detected as the `aster` filetype.

## LSP (Future)

When `aster-lsp` is available, enable it:

```lua
require("aster").setup({
  lsp = {
    cmd = { "aster-lsp" },
    -- settings = {},
  },
})
```

This configures the native `vim.lsp` client to connect to the Aster language server for diagnostics, hover, go-to-definition, and completions.
