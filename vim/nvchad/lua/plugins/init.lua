return {
    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre' -- uncomment for format on save
        config = function()
            require "configs.conform"
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "lus_ls", "ts_ls", "bashls", "gopls", "delve", "rust-analyzer",
                "clangd", "pyright", "yamlls", "jsonls", "sqlls", "html",
                "docker_language_server", "docker_compose_language_server",
            },
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            {
                "neovim/nvim-lspconfig",
                config = function()
                    require("nvchad.configs.lspconfig").defaults()
                    require "configs.lspconfig"
                end,
            }
        },
    },

    {
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
        "mg979/vim-visual-multi",
        event = "BufReadPost",
        init = function()
            require "configs.visual-multi"
        end,
    },

    {
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

}
