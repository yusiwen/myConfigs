require "nvchad.options"

-- add yours here!
local o = vim.o
o.relativenumber = true

-- 1. 开启无缝剪贴板机制
o.clipboard = "unnamedplus"

-- 2. 创建一个本地缓存变量，专门存你上一次在 nvim 里 y 的内容
local nvim_clipboard_cache = { "", "" }

-- 3. 自适应无缝全局剪贴板提供者
vim.g.clipboard = {
  name = 'SSH-Adaptive-Bridge',
  copy = {
    ['+'] = function(lines, regtype)
      -- 先同步更新到 Nvim 的内部缓存中，供 p 粘贴读取
      nvim_clipboard_cache = { lines, regtype }
      
      -- 处理发往 Host 宿主机的 OSC 52 转义逻辑
      local text = table.concat(lines, '\n')
      local base64 = vim.fn.system('base64', text):gsub('%s+', '')
      local osc52
      
      if os.getenv("TMUX") then
        -- 穿透 Byobu / Tmux 3.4 
        osc52 = string.format('\027Ptmux;\027\027]52;c;%s\a\027\\', base64)
      else
        -- 普通直连 SSH 
        osc52 = string.format('\027]52;c;%s\a', base64)
      end
      io.stderr:write(osc52)
    end,
    ['*'] = function(lines, regtype)
      nvim_clipboard_cache = { lines, regtype }
    end,
  },
  paste = {
    -- 核心突破：拒绝去 Host 读取网络剪贴板，直接秒回本地缓存，告别一切卡顿与未登记报错！
    ['+'] = function() return nvim_clipboard_cache[1], nvim_clipboard_cache[2] end,
    ['*'] = function() return nvim_clipboard_cache[1], nvim_clipboard_cache[2] end,
  },
}

