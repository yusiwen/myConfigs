---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>q"] = { ":q <CR>", "quit" },
    ["<leader>Q"] = { ":q! <CR>", "quit without saving" },
    ["<leader>W"] = { ":SudaWrite <CR>", "save file with sudo" },
  },
}

-- more keybinds!

return M
