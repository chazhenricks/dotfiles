return {
  {
    "tpope/vim-rails",
    config = function()
      -- "related" naviagation
      vim.keymap.set("n", "<leader>rr", "<CMD>R<CR>", {})
      vim.keymap.set("n", "<leader>rh", "<CMD>RV<CR>", {})

      --"alternate" navigation
      vim.keymap.set("n", "<leader>aa", "<CMD>A<CR>", {})
      vim.keymap.set("n", "<leader>ah", "<CMD>AV<CR>", {})

      --type navigation
      vim.keymap.set("n", "<leader>ec", "<CMD>Econtroller<CR>", {})
      vim.keymap.set("n", "<leader>ef", "<CMD>Efixtures<CR>", {})
      vim.keymap.set("n", "<leader>et", "<CMD>Efunctionaltest<CR>", {})
      vim.keymap.set("n", "<leader>eh", "<CMD>Ehelper<CR>", {})
      vim.keymap.set("n", "<leader>ei", "<CMD>Eintegrationtest<CR>", {})
      vim.keymap.set("n", "<leader>em", "<CMD>Emigration<CR>", {})
      vim.keymap.set("n", "<leader>es", "<CMD>Eschema<CR>", {})
    end,
  },
  { "tpope/vim-bundler" },
  { "tpope/vim-abolish" },
}
