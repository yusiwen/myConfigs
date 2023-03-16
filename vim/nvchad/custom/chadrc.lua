---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  transparency = true,

  theme = "nord",
  theme_toggle = { "nord", "onedark", "one_light" },

  hl_override = highlights.override,
  hl_add = highlights.add,

  statusline = {
    theme = "vscode"
  }
}

if vim.g.neovide then
  vim.opt.guifont = "Sarasa Term SC Nerd Font:h15"
end

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
