return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "bash",
        "embedded_template",
        "elixir",
        "eex",
        "erlang",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "heex",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash", "sh", "embedded_template", "elixir", "eex", "erlang", "go",
          "gomod", "gosum", "gowork", "heex", "html", "javascript",
          "javascriptreact", "json", "lua", "markdown", "python", "query",
          "regex", "ruby", "tsx", "typescript", "typescriptreact", "vim", "yaml",
        },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
  {
    "RRethy/nvim-treesitter-endwise",
  },
}
