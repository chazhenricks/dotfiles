return {
  { "tpope/vim-fugitive" },
  { "tpope/vim-rhubarb" },
  { "lewis6991/gitsigns.nvim" },

  vim.keymap.set("n", "<leader>gg", "<cmd>G<CR>", {}),
  vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line <cr>", {}),
  vim.keymap.set("n", "<leader>gs", "<cmd>Git status<CR>", {}),
  vim.keymap.set("n", "<leader>gco", ":Git checkout<space>", {}),
  vim.keymap.set("n", "<leader>gcb", ":Git checkout<space>", {}),
  vim.keymap.set("n", "<leader>gp", ":Git push", {}),
  vim.keymap.set("n", "<leader>gh", "<CMD>GBrowse<CR>", {}),
  vim.keymap.set("x", "<leader>gh", ":GBrowse<CR>", {}),
}
