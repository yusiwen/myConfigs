return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre' -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "configs.null-ls"
        end,
      },
    },
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
  	"williamboman/mason.nvim",
  	opts = {
  		pkgs = {
  			"lua-language-server", "stylua", "gopls",
  			"html-lsp", "css-lsp" , "prettier",
        "json-lsp", "dockerfile-language-server", "docker-compose-language-service",
        "yaml-language-server", "sqls", "rust-analyzer", "typescript-language-server", "pyright",
        "bash-language-server", "clangd", "cmake-language-server"
  		},
  	},
  },

  {
    "nvim-treesitter/nvim-treesitter",
    --opts = overrides.treesitter,
    build = ":TSUpdate",
    config = function()
      require "configs.treesitter"
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
          require "configs.treesitter-context"
        end,
      },
      {
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
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require "configs.better-escape"
    end,
  },

  {
    "phaazon/hop.nvim",
    event = "BufReadPost",
    branch = "v2",
    config = function()
      require "configs.hop"
    end,
  },

  {
    "mg979/vim-visual-multi",
    event = "BufReadPost",
    init = function()
      require "configs.visual-multi"
    end,
  },

}
