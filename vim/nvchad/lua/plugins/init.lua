return {
  {
    -- https://github.com/stevearc/conform.nvim
    -- Lightweight yet powerful formatter plugin for Neovim
    "stevearc/conform.nvim",
    -- event = 'BufWritePre' -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    -- https://github.com/mason-org/mason-lspconfig.nvim
    -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim.
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = true,
      ensure_installed = {
        "lus_ls", "ts_ls", "bashls", "gopls", "delve", "rust_analyzer",
        "clangd", "pyright", "yamlls", "jsonls", "sqlls", "html",
        "docker_language_server", "docker_compose_language_server",
      },
    },
    dependencies = {
      { 
        -- https://github.com/mason-org/mason.nvim
        -- Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP servers, linters, and formatters.
        "mason-org/mason.nvim",
        opts = {}
      },
      {
        -- https://github.com/neovim/nvim-lspconfig
        -- Quickstart configs for Nvim LSP.
        "neovim/nvim-lspconfig",
        config = function()
          require("nvchad.configs.lspconfig").defaults()
          require "configs.lspconfig"
        end,
      }
    },
  },

  {
    -- https://github.com/hedyhli/outline.nvim
    -- Fancy code outline sidebar to visualize and navigate code symbols in a tree hierarchy.
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      -- Your setup opts here
    },
  },

  {
    -- https://github.com/nvim-treesitter/nvim-treesitter
    -- Nvim Treesitter configurations and abstraction layer
    "nvim-treesitter/nvim-treesitter",
    --opts = overrides.treesitter,
    branch = 'main',
    build = ":TSUpdate",
    config = function()
      require "configs.treesitter"
    end,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
      },
      {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
          require "configs.treesitter-context"
        end,
      },
      {
        -- https://github.com/abecodes/tabout.nvim
        -- tabout plugin for neovim
        "abecodes/tabout.nvim",
        event = "InsertEnter",
        config = function()
          require "configs.tabout"
        end,
      },
    },
  },

  {
    'lambdalisue/suda.vim',
    event = { "BufNewFile", "BufReadPost" },
  },

  {
    "tpope/vim-surround",
    event = { "BufNewFile", "BufReadPost" },
  },

  {
    "tpope/vim-fugitive",
    event = { "BufNewFile", "BufReadPost" },
  },

  {
    -- https://github.com/rrethy/vim-illuminate
    -- automatically highlighting other uses of the word under the cursor using either LSP, Tree-sitter, or regex matching.
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require "configs.illuminate"
    end,
  },

  {
    "karb94/neoscroll.nvim",
    event = "BufReadPost",
  },

  {
    -- https://github.com/max397574/better-escape.nvim
    -- Map keys without delay when typing.
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require "configs.better-escape"
    end,
  },

  {
    -- https://github.com/folke/flash.nvim
    -- Navigate your code with search labels, enhanced character motions and Treesitter integration.
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },

  {
    -- https://github.com/mg979/vim-visual-multi
    -- Multiple cursors plugin for vim/neovim
    "mg979/vim-visual-multi",
    event = "BufReadPost",
    init = function()
      require "configs.visual-multi"
    end,
  },

  {
    -- https://github.com/folke/trouble.nvim
    -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing.
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  {
    -- https://github.com/akinsho/toggleterm.nvim
    -- A neovim lua plugin to help easily manage multiple terminal windows.
    'akinsho/toggleterm.nvim',
    version = "*",
    -- Trigger lazy loading on these commands
    cmd = { "ToggleTerm", "TermExec" },
    -- Trigger lazy loading on these keymaps
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm Float" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "ToggleTerm Horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "ToggleTerm Vertical" },
    },
    opts = {
      -- Configuration options (merged into setup)
      size = 20,
      open_mapping = [[<c-\>]], -- Still works as a toggle after loading
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float", -- Default direction
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 3,
      },
    },
  },

}
