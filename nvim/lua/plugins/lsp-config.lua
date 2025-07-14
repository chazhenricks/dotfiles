return {
  {
    "mason-org/mason.nvim",
    verson = "^1.0.0",
    priority = 100,
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    version = "^1.0.0",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    priority = 80,
    lazy = false,
    config = function()
      ensure_installed = {
        "ruby_lsp",
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    priority = 90,
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require "lspconfig"
      -- ruby
      lspconfig.ruby_lsp.setup {
        capabilities = capabilities,
      }

      --typescript
      lspconfig.ts_ls.setup {
        capabilities = capabilities,
      }

      --html
      lspconfig.html.setup {
        capabilities = capabilities,
      }

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "gl", vim.diagnostic.open_float, {})
      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
    end,
  },
}
