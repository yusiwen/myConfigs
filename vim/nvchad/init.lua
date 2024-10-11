---The file system path separator for the current platform.
local path_separator = "/"
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win32unix") == 1
if is_windows == true then
  path_separator = "\\"
end

---Split string into a table of strings using a separator.
---@param inputString string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
local split = function(inputString, sep)
  local fields = {}

  local pattern = string.format("([^%s]+)", sep)
  local _ = string.gsub(inputString, pattern, function(c)
    fields[#fields + 1] = c
  end)

  return fields
end

---Joins arbitrary number of paths together.
---@param ... string The paths to join.
---@return string
local path_join = function(...)
  local args = {...}
  if #args == 0 then
    return ""
  end

  local all_parts = {}
  if type(args[1]) =="string" and args[1]:sub(1, 1) == path_separator then
    all_parts[1] = ""
  end

  for _, arg in ipairs(args) do
    arg_parts = split(arg, path_separator)
    vim.list_extend(all_parts, arg_parts)
  end
  return table.concat(all_parts, path_separator)
end

vim.g.base46_cache = path_join(vim.fn.stdpath("data"), "base46") .. path_separator
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = path_join(vim.fn.stdpath("data"), "lazy", "lazy.nvim")

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(path_join(vim.g.base46_cache, "defaults"))
dofile(path_join(vim.g.base46_cache, "statusline"))

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)
