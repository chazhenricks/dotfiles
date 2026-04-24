return {
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod" },
    build = ":lua require('go.install').update_all_sync()",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("go").setup({
        lsp_cfg = {
          capabilities = capabilities,
          settings = {
            gopls = {
              gofumpt = true,
              analyses = {
                unusedparams = true,
                ST1000 = false,
              },
              staticcheck = true,
            },
          },
        },
        lsp_inlay_hints = { enable = false },
        lsp_keymaps = false,
        luasnip = true,
      })
    end,
  },
}
