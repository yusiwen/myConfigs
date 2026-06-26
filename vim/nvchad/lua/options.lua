require "nvchad.options"

-- add yours here!

local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
o.relativenumber = true
o.clipboard = "unnamedplus"

-- 智能自适应终端与 Tmux/Byobu 剪贴板配置
vim.g.clipboard = {
  name = 'OSC52-Adaptive',
  copy = {
    ['+'] = function(lines, _)
      local text = table.concat(lines, '\n')
      local base64 = vim.fn.system('base64', text):gsub('%s+', '')
      local osc52
      
      -- 判断当前是否处于 Tmux / Byobu 会话中
      if os.getenv("TMUX") then
        -- Tmux 3.4/Byobu 需要 \027Ptmux;\027 外壳进行透传
        osc52 = string.format('\027Ptmux;\027\027]52;c;%s\a\027\\', base64)
      else
        -- 普通 SSH 会话，直接发送标准的 OSC 52 序列即可
        osc52 = string.format('\027]52;c;%s\a', base64)
      end
      
      io.stderr:write(osc52)
    end,
    ['*'] = function(lines, _)
      local text = table.concat(lines, '\n')
      local base64 = vim.fn.system('base64', text):gsub('%s+', '')
      local osc52
      
      if os.getenv("TMUX") then
        osc52 = string.format('\027Ptmux;\027\027]52;c;%s\a\027\\', base64)
      else
        osc52 = string.format('\027]52;c;%s\a', base64)
      end
      
      io.stderr:write(osc52)
    end,
  },
  paste = { ['+'] = function() return {} end, ['*'] = function() return {} end },
}
