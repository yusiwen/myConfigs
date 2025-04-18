-- EXAMPLE 
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>.', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts, "Go to declaration")
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts, "Go to definition")
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts, "Go to implementation")
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts, "Hover text")
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts, "Show signature")
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts, "Add workspace folder")
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts, "Remove workspace folder")
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts, "List workspace folders")
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts, "Go to type definition")
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts, "Rename")
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts, "LSP: Code actions")
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts, "Format file")
  end,
})

--- LSP
local servers = { "html", "cssls", }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- typescript
lspconfig.ts_ls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

lspconfig.gopls.setup {
  on_attach = attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern(".git", "go.mod"),
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    gopls = {
      gofumpt = true,
      experimentalPostfixCompletions = true,
      staticcheck = true,
      usePlaceholders = true,
    },
  },
}

lspconfig.pyright.setup {}
lspconfig.rust_analyzer.setup {}
lspconfig.yamlls.setup {
  settings = {
    yaml = {
      schemas = { kubernetes = "globPattern" },
    }
  }
}

lspconfig.clangd.setup {}
