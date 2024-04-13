local colorscheme = "nordic"

vim.api.nvim_set_hl(0, "Comment", { italic = true })
require("nordic").setup {
  italic_comments = true,
}

local status_ok, _ = pcall(vim.cmd.colorscheme, colorscheme)
if not status_ok then
  return
end
