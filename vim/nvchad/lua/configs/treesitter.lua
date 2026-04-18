local configs = require("nvim-treesitter.configs")

configs.setup({
  auto_install = true,
  ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "python", "rust", "java", "bash", "zsh", "javascript", "typescript", "css", "html" },
  highlight = {
    enable = true,
  },
})
