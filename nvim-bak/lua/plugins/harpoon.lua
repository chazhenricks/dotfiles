return {
  "ThePrimeagen/harpoon",
  config = function()
    local harpoon = require "harpoon"
    harpoon.setup()
    require("telescope").load_extension "harpoon"
    vim.keymap.set("n", "<leader>jm", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>", {})
    vim.keymap.set("n", "<leader>ja", "<cmd>lua require('harpoon.mark').add_file()<CR>", {})
    vim.keymap.set("n", "<leader>j1", "<cmd>lua require('harpoon.ui').nav_file(1)<CR>", {})
    vim.keymap.set("n", "<leader>j2", "<cmd>lua require('harpoon.ui').nav_file(2)<CR>", {})
    vim.keymap.set("n", "<leader>j3", "<cmd>lua require('harpoon.ui').nav_file(3)<CR>", {})
    vim.keymap.set("n", "<leader>j4", "<cmd>lua require('harpoon.term').gotoTerminal(1)<CR>", {})
  end,
}
