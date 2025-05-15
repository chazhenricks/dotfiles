local colorscheme = "everforest"

-- vim.api.nvim_set_hl(0, "Comment", { italic = true })
-- require("nordic").setup {
--   italic_comments = true,
-- }

vim.g["everforest_background"] = "hard"
local status_ok, _ = pcall(vim.cmd.colorscheme, colorscheme)
if not status_ok then
  return
end
