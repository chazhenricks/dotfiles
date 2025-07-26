return {
  {
    "mason-org/mason.nvim", 
    version="^1.0.0",
    lazy = false,
    priority = 100, -- Make sure this loads first
    config = function()
      require("mason").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    priority = 90, -- This loads second
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.ruby_lsp.setup({
        capabilities = capabilities
      })

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    version="^1.0.0",
    lazy = false,
    priority = 80, -- This loads third
    opts = {
      ensure_installed = { "ruby_lsp" }
    },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },
}
