return {
  --formatting
  {
    "stevearc/conform.nvim",
    config = function()
      local conform = require "conform"
      conform.setup {
        formatters_by_ft = {
          lua = { "stylua" },
          python = function(bufnr)
            if require("conform").get_formatter_info("ruff_format", bufnr).available then
              return { "ruff_format" }
            else
              return { "isort", "black" }
            end
          end,
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          eruby = { "htmlbeautifier" },
          html = { "htmlbeautifier" },
          ruby = { "rubocop" },
          markdown = { "prettierd" },
        },
        formatters = {
          stylua = {
            args = {
              "--search-parent-directories",
              "--indent-type",
              "Spaces",
              "--stdin-filepath",
              "$FILENAME",
              "-",
            },
          },
        },
        format_on_save = {
          timeout_ms = 3000,
          lsp_format = "fallback",
        },
        -- Format command key binding
        vim.keymap.set("n", "<leader>fmt", function()
          conform.format { async = true, lsp_fallback = true }
        end, { desc = "Format buffer" }),
      }
    end,
  },
  -- Linter
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"

      -- Configure linters for different filetypes
      lint.linters_by_ft = {

        -- javascript bullshit
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },

        -- Ruby development
        ruby = { "rubocop" },
        eruby = { "erb_lint" },
      }

      -- Configure specific linters
      lint.linters.rubocop.args = {
        "--format",
        "json",
        "--force-exclusion", -- Respect .rubocop_todo.yml
        "--stdin",
        "$FILENAME",
      }

      lint.linters.eslint.args = {
        "--format",
        "json",
        "--stdin",
        "--stdin-filename",
        "$FILENAME",
      }

      -- Set up lint on save
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
