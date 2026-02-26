return {
  -- copilot
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", {})
      vim.keymap.set("n", "<leader>ce", ":Copilot enable <CR>", {})
      vim.keymap.set("n", "<leader>cd", ":Copilot disable <CR>", {})
      vim.keymap.set("i", "<Plug>(vimrc:copilot-dummy-map)", 'copilot#Accept("")', {
        expr = true,
        replace_keycodes = true,
        silent = true,
        desc = "Copilot dummy map",
      })
    end,
  },
}
