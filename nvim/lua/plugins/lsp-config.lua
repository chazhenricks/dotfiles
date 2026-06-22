return {
  {
    "mason-org/mason.nvim",
    verson = "^1.0.0",
    priority = 100,
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    version = "^1.0.0",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    priority = 80,
    lazy = false,
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = {
          "gopls",
          "ruby_lsp",
          "elixirls",
          -- erlangls built from main branch manually (1.1.0 incompatible with OTP 29)
        },
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    priority = 90,
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.config("ts_ls", {})

      vim.lsp.config("basedpyright", {
        before_init = function(_, config)
          local cwd = vim.fn.getcwd()
          local dir_name = vim.fn.fnamemodify(cwd, ":t")

          local venv_paths = {
            cwd .. "/.venv/bin/python",
            cwd .. "/venv/bin/python",
            cwd .. "/" .. dir_name .. "/bin/python",
          }

          for _, path in ipairs(venv_paths) do
            if vim.fn.filereadable(path) == 1 then
              config.settings.python = config.settings.python or {}
              config.settings.python.pythonPath = path
              break
            end
          end
        end,

        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodesForTypes = true,
              diagnosticMode = "workspace",
            },
          },
          python = {
            pythonPath = "python3",
          },
        },
      })

      vim.lsp.config("html", {})
      vim.lsp.config("ruby_lsp", {})
      vim.lsp.config("elixirls", {})
      vim.lsp.enable { "ts_ls", "basedpyright", "html", "ruby_lsp", "elixirls" }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function()
          vim.cmd [[
      nnoremap <buffer> <CR> <CR>:cclose<Bar>lclose<CR>
    ]]
        end,
      })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "gl", vim.diagnostic.open_float, {})
      vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
    end,
  },
}
