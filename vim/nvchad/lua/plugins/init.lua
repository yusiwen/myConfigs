return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre' -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
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
  --
  {
  	"williamboman/mason.nvim",
  	opts = {
  		ensure_installed = {
  			"lua-language-server", "stylua", "gopls",
  			"html-lsp", "css-lsp" , "prettier",
        "json-lsp", "dockerfile-language-server", "docker-compose-language-service",
        "yaml-language-server", "sqls", "rust-analyzer", "typescript-language-server", "pyright",
        "bash-language-server", "clangd", "cmake-language-server"
  		},
  	},
  },
  --
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- }
  {
    'lambdalisue/suda.vim',
    event = "BufReadPost",
  },

  {
    "tpope/vim-surround",
    event = "BufReadPost",
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

}
