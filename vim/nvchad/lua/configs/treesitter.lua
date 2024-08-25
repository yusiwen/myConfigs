local configs = require("nvim-treesitter.configs")

configs.setup({
    ensure_installed = {
      "bash", "c", "cpp", "go", "groovy",
      "java", "javascript", "html", "yaml", "xml",
      "lua", "nginx", "python", "rust",
      "sql", "vim", "vimdoc"
    },
    sync_install = false,
    highlight = {
      enable = true,
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
      end,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },  
  })