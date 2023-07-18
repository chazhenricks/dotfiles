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

-- Plugins --

-- NvimTree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>ft", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fp", ":Telescope projects<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)

-- Git
keymap("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", opts)
keymap("n", "<leader>gb", "<cmd>Gitsigns blame_line <cr>", opts)
keymap("n", "<leader>gs", "<cmd>Git status<CR>", opts)
keymap("n", "<leader>gco", ":Git checkout<space>", opts)
keymap("n", "<leader>gc", ":Git checkout<space>", opts)
keymap("n", "<Leader>gc", ":Git commit -v -q<CR>", opts) -- commits all files
keymap("n", "<Leader>gt", ":Git commit -v -q %:p<CR>", opts) -- commits current file
keymap("n", "<leader>ga", ":Git add %:p <CR><CR>", opts) -- adds current file
keymap("n", "<leader>gaa", ":Git add . <CR><CR>", opts)

-- Comment
keymap("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", opts)
keymap("x", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)

-- DAP
keymap("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts)
keymap("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts)
keymap("n", "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", opts)
keymap("n", "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", opts)
keymap("n", "<leader>dO", "<cmd>lua require'dap'.step_out()<cr>", opts)
keymap("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", opts)
keymap("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", opts)
keymap("n", "<leader>du", "<cmd>lua require'dapui'.toggle()<cr>", opts)
keymap("n", "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", opts)

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
keymap("n", "<leader>ce", ":Copilot enable <CR>")
keymap("n", "<leader>cd", ":Copilot disable <CR>")
keymap("i", "<C-J>", 'copilot#Accept("<CR>")', opts)


-- Compile/run C file 
keymap("n", "<leader>cr", ":terminal gcc % && ./a.out <CR>")

-- Addind semicolon at the end of the line
keymap("n", "<leader>;;", "A;<esc>o", opts)
keymap("i", ";;", "<esc>A;<esc>o", opts)


-- exist and insert new line above current 
keymap("i", "<C-o>", "<esc>O", opts)
keymap("i", "<C-]>", "{<CR>}<esc>O", opts)
