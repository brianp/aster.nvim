local M = {}

function M.setup(opts)
  opts = opts or {}

  -- Register the filetype
  vim.filetype.add({
    extension = {
      aster = "aster",
    },
  })

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
