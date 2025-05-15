local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
-- test
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile>
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
  git = {
    clone_timeout = 300, -- Timeout, in seconds, for git clones
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
  use { "wbthomason/packer.nvim" } -- Have packer manage itself
  use { "nvim-lua/plenary.nvim" } -- Useful lua functions used by lots of plugins
  use { "numToStr/Comment.nvim" }
  use { "JoosepAlviste/nvim-ts-context-commentstring" }
  use { "kyazdani42/nvim-web-devicons" }
  use { "kyazdani42/nvim-tree.lua" }
  use { "nvim-lualine/lualine.nvim" }
  use { "moll/vim-bbye" }
  use { "akinsho/toggleterm.nvim" }
  use { "ahmedkhalf/project.nvim" }
  use { "lukas-reineke/indent-blankline.nvim" }
  use { "goolord/alpha-nvim" }
  use { "vim-test/vim-test", opt = false }
  use { "mattn/emmet-vim" }

  --rails
  use { "tpope/vim-rails" }
  use { "tpope/vim-bundler" }
  use { "tpope/vim-abolish" }

  -- Colorschemes
  use { "lunarvim/darkplus.nvim", commit = "13ef9daad28d3cf6c5e793acfc16ddbf456e1c83" }
  use "lunarvim/colorschemes" -- A bunch of colorschemes you can try out
  use { "AlexvZyl/nordic.nvim" }
  use { "rebelot/kanagawa.nvim" }
  use { "sainnhe/everforest" }
  -- cmp plugins
  use { "hrsh7th/nvim-cmp" } -- The completion plugin
  use { "hrsh7th/cmp-buffer" } -- buffer completions
  use { "hrsh7th/cmp-path" } -- path completions
  use { "saadparwaiz1/cmp_luasnip" } -- snippet completions
  use { "hrsh7th/cmp-nvim-lsp" }
  use { "hrsh7th/cmp-nvim-lua" }

  -- snippets
  use { "L3MON4D3/LuaSnip", commit = "8f8d493e7836f2697df878ef9c128337cbf2bb84" } --snippet engine
  use { "rafamadriz/friendly-snippets", commit = "2be79d8a9b03d4175ba6b3d14b082680de1b31b1" } -- a bunch of snippets to use

  -- LSP
  use { "neovim/nvim-lspconfig" } -- enable LSP
  use { "mason-org/mason.nvim", commit = "fc98833" }
  use { "mason-org/mason-lspconfig.nvim", commit = "1a31f824b9cd5bc6f342fc29e9a53b60d74af245" }
  use { "jose-elias-alvarez/null-ls.nvim" } -- for formatters and linters
  use { "RRethy/vim-illuminate" }
  use { "lbrayner/vim-rzip" }

  -- Telescope
  use { "nvim-telescope/telescope.nvim" }
  use { "nvim-telescope/telescope-live-grep-args.nvim" }
  use { "stevearc/oil.nvim" }

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
  }

  -- Git
  use { "lewis6991/gitsigns.nvim" }
  use { "tpope/vim-fugitive" }
  use { "tpope/vim-rhubarb" }

  -- Copilot
  use { "github/copilot.vim" }

  -- Harppoon (WIP)
  use { "ThePrimeagen/harpoon" }

  -- Tmux/Vim integration
  use { "christoomey/vim-tmux-navigator" }

  -- DAP
  use {
    "mfussenegger/nvim-dap",
    requires = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mxsdev/nvim-dap-vscode-js",
    },
  }
  use { "jay-babu/mason-nvim-dap.nvim" }
  use {
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
  }
  use { "nvim-telescope/telescope-dap.nvim" }
  use { "Joakker/lua-json5", build = "./install.sh" }

  -- Database
  use { "tpope/vim-dadbod" }
  use { "kristijanhusak/vim-dadbod-ui" }
  use { "kristijanhusak/vim-dadbod-completion" }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
