-- Indentation rules for Aster (indentation-based syntax like Python)

vim.b.did_indent = true

vim.bo.indentexpr = "v:lua.require'aster.indent'.get_indent(v:lnum)"
vim.bo.indentkeys = "o,O,!^F,=else,=elif,=catch"

local M = {}

-- Patterns that increase indent on the next line
local increase_patterns = {
  "^%s*def%s",
  "^%s*class%s",
  "^%s*trait%s",
  "^%s*enum%s",
  "^%s*if%s",
  "^%s*elif%s",
  "^%s*else%s*$",
  "^%s*while%s",
  "^%s*for%s",
  "^%s*match%s",
  "^%s*catch%s*$",
  "^%s*async%s+scope",
  "=>%s*$",
}

-- Patterns that decrease indent for the current line
local decrease_patterns = {
  "^%s*else%s*$",
  "^%s*elif%s",
  "^%s*catch%s",
}

function M.get_indent(lnum)
  if lnum <= 1 then
    return 0
  end

  -- Find previous non-blank line
  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  if prev_lnum == 0 then
    return 0
  end

  local prev_line = vim.fn.getline(prev_lnum)
  local prev_indent = vim.fn.indent(prev_lnum)
  local sw = vim.bo.shiftwidth

  local indent = prev_indent

  -- Check if previous line should increase indent
  for _, pattern in ipairs(increase_patterns) do
    if prev_line:match(pattern) then
      indent = prev_indent + sw
      break
    end
  end

  -- Check if current line should decrease indent
  local cur_line = vim.fn.getline(lnum)
  for _, pattern in ipairs(decrease_patterns) do
    if cur_line:match(pattern) then
      indent = indent - sw
      break
    end
  end

  return math.max(0, indent)
end

return M
