require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>W", ":SudaWrite <CR>", { desc = "save file with sudo" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>fr", "<cmd>Telescope resume<CR>", { desc = "telescope resume" })

map("n", "<leader>G", "<cmd>Git<CR>", { desc = "fugitive" })

map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle nvimtree" })
