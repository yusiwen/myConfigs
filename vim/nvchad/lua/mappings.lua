require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>W", ":SudaWrite <CR>", { desc = "save file with sudo" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>fr", "<cmd>Telescope resume<CR>", { desc = "telescope resume" })

map("n", "<leader>G", "<cmd>Git<CR>", { desc = "fugitive" })

map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle nvimtree" })

-- 获取 gitsigns 模块的辅助函数
local function gs_cmd(fn_name)
  return function()
    local ok, gs = pcall(require, "gitsigns")
    if ok then
      gs[fn_name]()
    end
  end
end

-- 下一个 Hunk
map("n", "]c", function()
  if vim.wo.diff then
    return "]c"
  end
  vim.schedule(gs_cmd("next_hunk"))
  return "<Ignore>"
end, { expr = true, desc = "Jump to next hunk" })

-- 上一个 Hunk
map("n", "[c", function()
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(gs_cmd("prev_hunk"))
  return "<Ignore>"
end, { expr = true, desc = "Jump to prev hunk" })

-- 1. 手动切换：一键开启/关闭行尾虚拟 Blame 文本
map("n", "<leader>gb", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok then gs.toggle_current_line_blame() end
end, { desc = "Git toggle current line blame" })

-- 2. 手动弹窗：在光标处弹出完整的 Commit Blame 悬浮窗 (NvChad默认已带，这里可自定义按键)
map("n", "<leader>gB", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok then gs.blame_line({ full = true }) end
end, { desc = "Git full blame popup" })
