return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")
    oil.setup({
      view_options = {
        show_hidden = true
      }
    })
    -- Open Parent Directory In current window
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Parent Directory" })

    --Oopen Parent directory in floating window
    --vim.keymaps.set("n", "<space>-", require("oil").toggle_float)
  end
}
