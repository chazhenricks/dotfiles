return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "RRethy/nvim-treesitter-endwise" },
    build = ":TSUpdate",
    config = function()
      local config = require "nvim-treesitter.configs"
      config.setup {
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true, disable = { "yaml", "ruby" } },
        endwise = { enable = true },
        ensure_installed = {
          "bash",
          "embedded_template",
          "go",
          "gomod",
          "gosum",
          "gowork",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "ruby",
          "tsx",
          "typescript",
          "vim",
          "yaml",
        },
        context_commentstring = {
          config = {
            javascript = {
              __default = "// %s",
              jsx_element = "{/* %s */}",
              jsx_fragment = "{/* %s */}",
              jsx_attribute = "// %s",
              comment = "// %s",
            },
            typescript = { __default = "// %s", __multiline = "/* %s */" },
          },
        },
      }
    end,
  },
}
