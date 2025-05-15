-- vim test options
-- disable warnings in pytest
vim.g["test#python#pytest#options"] = "-W ignore"
vim.g["test#javascript#vitest#options"] = "--coverage"

vim.g["test#javascript#runner"] = "vitest"
vim.g["test#typescript#runner"] = "vitest"
