local db_ok, db = pcall(require, "vim-dadbod")
if not db_ok then
  return
end
local db_ui_ok, db_ui = pcall(require, "vim-dadbod-ui")
if not db_ui_ok then
  return
end

-- Configure vim-dadbod-ui
vim.g.db_ui_save_location = vim.fn.expand "~/.config/nvim/db_ui"
vim.g.db_ui_use_nerd_fonts = 1

-- Optional: Set up key mappings
vim.api.nvim_set_keymap("n", "<leader>du", ":DBUIToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>df", ":DBUIFindBuffer<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>dr", ":DBUIRenameBuffer<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>dl", ":DBUILastQueryInfo<CR>", { noremap = true, silent = true })

-- Optional: Set up autocommands
vim.cmd [[
  augroup DadbodSql
    autocmd!
    autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
  augroup END
]]
