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
          go = { "goimports", "gofumpt" },
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

        -- Go
        go = { "golangcilint" },

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

      -- Args must be set on eslint_d (the linter actually used), not eslint
      lint.linters.eslint_d.args = {
        "--format",
        "json",
        "--stdin",
        "--stdin-filename",
        "$FILENAME",
      }

      -- Find monorepo/project root so eslint_d's cwd has access to root node_modules
      -- (fixes "Cannot find package ... @my-etsy/eslint-config" when buffer is in a subdir)
      local function find_lint_root()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then return nil end
        local dir = vim.fn.fnamemodify(path, ":p:h")
        while dir ~= nil and dir ~= "" and dir ~= "/" do
          if vim.fn.isdirectory(dir .. "/node_modules/@my-etsy/eslint-config") == 1 then
            return dir
          end
          if vim.fn.filereadable(dir .. "/pnpm-workspace.yaml") == 1 then
            return dir
          end
          local parent = vim.fn.fnamemodify(dir, ":h")
          if parent == dir then break end
          dir = parent
        end
        return nil
      end

      -- Set up lint on save; run eslint_d from project root so shared config resolves
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          local root = find_lint_root()
          require("lint").try_lint(nil, root and { cwd = root } or {})
        end,
      })
    end,
  },
}
