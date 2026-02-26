return {
  {
    "tpope/vim-rails",
    config = function()
      vim.keymap.set("n", "<leader>rr", "<CMD>R<CR>", {})
      vim.keymap.set("n", "<leader>aa", "<CMD>A<CR>", {})
    end,
  },
  { "tpope/vim-bundler" },
  { "tpope/vim-abolish" },
}
