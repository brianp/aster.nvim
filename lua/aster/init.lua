local M = {}

function M.setup(opts)
  opts = opts or {}

  -- Register the filetype
  vim.filetype.add({
    extension = {
      aster = "aster",
    },
  })

  -- Set up tree-sitter if nvim-treesitter is available
  if opts.treesitter ~= false then
    local ok, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok then
      local parser_config = parsers.get_parser_configs()
      parser_config.aster = {
        install_info = {
          url = opts.grammar_path or (vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h") .. "/tree-sitter-aster"),
          files = { "src/parser.c" },
          branch = "main",
          generate_requires_npm = false,
          requires_generate_from_grammar = true,
        },
        filetype = "aster",
      }
    end
  end

  -- Set up LSP if configured
  if opts.lsp then
    M.setup_lsp(opts.lsp)
  end
end

function M.setup_lsp(lsp_opts)
  lsp_opts = lsp_opts or {}
  local cmd = lsp_opts.cmd or { "aster-lsp" }

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "aster",
    callback = function()
      vim.lsp.start({
        name = "aster-lsp",
        cmd = cmd,
        root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml", ".git" }, { upward = true })[1]),
        settings = lsp_opts.settings or {},
      })
    end,
  })
end

return M
