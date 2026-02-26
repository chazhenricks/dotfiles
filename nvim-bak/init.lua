-- -------------------------------------------------------
-- Init lazyvim, setup path, and download if not installed
-- -------------------------------------------------------
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- -------------------------------------------------------
--global options and keymaps
-- -------------------------------------------------------
require "vim-options"

-- -------------------------------------------------------
-- plugins and their configs/keymaps
-- -------------------------------------------------------
require("lazy").setup {
  spec = {
    { import = "plugins" }, --look in lua/plugins for configs
  },
  change_detection = { enabled = false }, -- dont tell me each time the config changes
}
