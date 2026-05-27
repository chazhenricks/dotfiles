return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
  ft = { "markdown" },
  config = function()
    local render_markdown = require "render-markdown"
    render_markdown.setup {
      pipe_table = {
        preset = "round",
        cell = "padded",
        padding = 1,
        min_width = 1,
      },
    }
    vim.keymap.set("n", "<leader>mp", "<CMD>RenderMarkdown preview<CR>", {})
    vim.keymap.set("n", "<leader>mt", "<CMD>RenderMarkdown toggle<CR>", {})
  end,
}
