local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

-- format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- make C files stfu
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.offsetEncoding = { "utf-16" }
require("lspconfig").clangd.setup { capabilities = capabilities }

-- https://github.com/prettier-solidity/prettier-plugin-solidity
null_ls.setup {
  debug = true,
  sources = {
    formatting.prettier.with {
      extra_filetypes = { "toml" },
    },
    formatting.black.with { extra_args = { "--fast" } },
    formatting.stylua,
    formatting.google_java_format,
    diagnostics.flake8.with {
      extra_args = {
        "--max-line-length=120",
        "--ignore=W391",
      },
    },
    diagnostics.eslint_d,
    formatting.clang_format.with {
      extra_args = {
        "--fallback-style=Google",
      },
    },
    diagnostics.clang_check,
  },
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds {
        group = augroup,
        buffer = bufnr,
      }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr }
        end,
      })
    end
  end,
}
