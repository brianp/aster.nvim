local M = {}

--- Find the tree-sitter-aster source directory within this plugin
local function get_grammar_dir()
  local source = debug.getinfo(1, "S").source:sub(2)
  local plugin_root = vim.fn.fnamemodify(source, ":h:h:h")
  return plugin_root .. "/tree-sitter-aster"
end

--- Get the directory where nvim-treesitter installs .so files,
--- falling back to neovim's built-in parser path
local function get_parser_install_dir()
  local ok, ts_config = pcall(require, "nvim-treesitter.config")
  if ok and ts_config.get_install_dir then
    local dir = ts_config.get_install_dir("parser")
    if dir then
      return dir
    end
  end
  return vim.fn.stdpath("data") .. "/site/parser"
end

--- Compile the tree-sitter parser from C source if not already installed
local function ensure_parser()
  local install_dir = get_parser_install_dir()
  local parser_path = install_dir .. "/aster.so"

  -- Already compiled
  if vim.uv.fs_stat(parser_path) then
    return true
  end

  local grammar_dir = get_grammar_dir()
  local src_dir = grammar_dir .. "/src"
  local parser_c = src_dir .. "/parser.c"
  local scanner_c = src_dir .. "/scanner.c"

  -- Source files must exist
  if not vim.uv.fs_stat(parser_c) then
    return false
  end

  -- Ensure install directory exists
  vim.fn.mkdir(install_dir, "p")

  -- Compile
  local cc = vim.fn.getenv("CC")
  if cc == vim.NIL or cc == "" then
    cc = "cc"
  end

  local obj_files = {}
  local compile_args_base = { cc, "-o", "", "-c", "-I", src_dir, "-shared", "-Os", "-fPIC" }

  -- Compile parser.c
  local parser_o = vim.fn.tempname() .. "_parser.o"
  local result = vim.fn.system({
    cc, "-c", "-o", parser_o, "-I", src_dir, "-Os", "-fPIC", parser_c,
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("[aster.nvim] Failed to compile parser.c: " .. result, vim.log.levels.ERROR)
    return false
  end
  table.insert(obj_files, parser_o)

  -- Compile scanner.c if it exists
  if vim.uv.fs_stat(scanner_c) then
    local scanner_o = vim.fn.tempname() .. "_scanner.o"
    result = vim.fn.system({
      cc, "-c", "-o", scanner_o, "-I", src_dir, "-Os", "-fPIC", scanner_c,
    })
    if vim.v.shell_error ~= 0 then
      vim.notify("[aster.nvim] Failed to compile scanner.c: " .. result, vim.log.levels.ERROR)
      return false
    end
    table.insert(obj_files, scanner_o)
  end

  -- Link into .so
  local link_cmd = { cc, "-o", parser_path, "-shared" }
  for _, o in ipairs(obj_files) do
    table.insert(link_cmd, o)
  end
  result = vim.fn.system(link_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("[aster.nvim] Failed to link parser: " .. result, vim.log.levels.ERROR)
    return false
  end

  -- Cleanup object files
  for _, o in ipairs(obj_files) do
    os.remove(o)
  end

  vim.notify("[aster.nvim] Parser compiled successfully", vim.log.levels.INFO)
  return true
end

function M.setup(opts)
  opts = opts or {}

  -- Register the filetype
  vim.filetype.add({
    extension = {
      aster = "aster",
      astr = "aster",
    },
  })

  -- Compile and register tree-sitter parser
  if opts.treesitter ~= false then
    local compiled = ensure_parser()
    if compiled then
      vim.treesitter.language.register("aster", "aster")
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
