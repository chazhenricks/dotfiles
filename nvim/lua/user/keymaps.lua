local keymap = vim.keymap.set
-- Silent keymap option
local opts = { silent = true }

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- split panes
keymap("n", "<leader>-", "<C-w>s", opts)
keymap("n", "<leader>\\", "<C-w>v", opts)

keymap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
-- because im a child
keymap("n", "<leader>poo", "i ew who farted? <esc>", opts)

--Manually re-balance available panes
keymap("n", "<leader>fs", ":wincmd _<CR> :wincmd |<CR>", opts) -- make full size
keymap("n", "<leader>=", ":wincmd =<CR>", opts) -- re-balance

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Make new file in current directory
keymap("n", "<leader>nf", ":e %:h/")

-- Navigate buffers<leader>nf
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Clear highlights
keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)

-- Close buffers
keymap("n", "<S-q>", "<cmd>Bdelete!<CR>", opts)

-- Better paste
keymap("v", "p", '"_dP', opts)

-- Open Config
keymap("n", "<leader>c", ":e $MYVIMRC <CR>", opts)

-- Copy/Paste from system clipboard
keymap("v", "<leader>y", '"+y', opts) -- copy to clipboard
keymap("v", "<leader>Y", '"+yg_', opts) -- copy till end of line to clipboard
keymap("v", "<leader>p", '"+p', opts)
keymap("v", "<leader>P", '"+P', opts)
keymap("n", "<leader>p", '"+p', opts)
keymap("n", "<leader>P", '"+P', opts)

keymap("n", "<leader>ln", ":set rnu! <CR>", opts)
-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Visual
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)

-- Visual BLock Mode
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- make current bash file executable within vim
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", opts)

-- alias for quit
keymap("n", "<leader>q", "<cmd>q<CR>", opts)

-- alias' for write all and quit all
keymap("n", "<leader>qq", "<cmd>qa<CR>", opts)
keymap("n", "<leader>ww", "<cmd>wa<CR>", opts)

-- Plugins --

-- NvimTree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>ft", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fp", ":Telescope projects<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)

-- Git
keymap("n", "<leader>gg", "<cmd>G<CR>", opts)
keymap("n", "<leader>gb", "<cmd>Gitsigns blame_line <cr>", opts)
keymap("n", "<leader>gs", "<cmd>Git status<CR>", opts)
keymap("n", "<leader>gco", ":Git checkout<space>", opts)
keymap("n", "<leader>gcb", ":Git checkout<space>", opts)
keymap("n", "<leader>gp", ":Git push", opts)

-- Comment
keymap("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", opts)
keymap("x", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)

-- Lsp
keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", opts)

-- Harpoon
keymap("n", "<leader>ja", "<cmd>lua require('harpoon.mark').add_file()<CR>")
keymap("n", "<leader>jm", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>")
keymap("n", "<leader>j1", "<cmd>lua require('harpoon.ui').nav_file(1)<CR>")
keymap("n", "<leader>j2", "<cmd>lua require('harpoon.ui').nav_file(2)<CR>")
keymap("n", "<leader>j3", "<cmd>lua require('harpoon.ui').nav_file(3)<CR>")
keymap("n", "<leader>j4", "<cmd>lua require('harpoon.term').gotoTerminal(1)<CR>")

-- Copilot
vim.g.copilot_no_tab_map = true
keymap("n", "<leader>ce", ":Copilot enable <CR>")
keymap("n", "<leader>cd", ":Copilot disable <CR>")
-- needed to call the cmp map to do copilot accept.
-- see cmp.lua for more info
keymap("i", "<Plug>(vimrc:copilot-dummy-map)", 'copilot#Accept("")', {
  expr = true,
  replace_keycodes = true,
  silent = true,
  desc = "Copilot dummy map",
})

-- Compile/run C file
keymap("n", "<leader>cr", ":terminal gcc % && ./a.out <CR>")

-- Addind semicolon at the end of the line
keymap("n", "<leader>;;", "A;<esc>o", opts)
keymap("i", ";;", "<esc>A;<esc>o", opts)

-- exist and insert new line above current
keymap("i", "<C-o>", "<esc>O", opts)
keymap("i", "<C-]>", "{<CR>}<esc>O", opts)
