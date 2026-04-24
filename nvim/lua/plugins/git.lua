return {
  {
    "tpope/vim-fugitive",
    init = function()
      local function toggle_more()
        vim.o.more = not vim.o.more
        vim.notify(vim.o.more and "'more' enabled" or "'more' disabled")
      end

      vim.keymap.set("n", "<leader>um", toggle_more, { desc = "Toggle vim more prompt" })

      local function fugitive_commit_no_more()
        local save_more = vim.o.more
        vim.o.more = false

        local ok, err = pcall(function()
          vim.cmd "Git commit"
        end)

        vim.o.more = save_more

        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive",
        callback = function(event)
          vim.keymap.set("n", "<leader>cc", fugitive_commit_no_more, {
            buffer = event.buf,
            desc = "Fugitive commit with nomore",
          })
        end,
      })

      vim.keymap.set("n", "<leader>gg", "<cmd>G<CR>", { desc = "Fugitive status" })
      vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", { desc = "Git blame line" })
      vim.keymap.set("n", "<leader>gs", "<cmd>Git status<CR>", { desc = "Git status" })
      vim.keymap.set("n", "<leader>gco", ":Git checkout<space>", { desc = "Git checkout" })
      vim.keymap.set("n", "<leader>gcb", ":Git checkout<space>", { desc = "Git checkout branch" })
      vim.keymap.set("n", "<leader>gp", ":Git push", { desc = "Git push" })
      vim.keymap.set("n", "<leader>gh", "<cmd>GBrowse<CR>", { desc = "Open in GitHub" })
      vim.keymap.set("x", "<leader>gh", ":GBrowse<CR>", { desc = "Open selection in GitHub" })
    end,
  },

  { "tpope/vim-rhubarb" },
  { "lewis6991/gitsigns.nvim" },
}
