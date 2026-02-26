return {
  {
    "sainnhe/everforest",
    lazy = false,
    name = "everforest",
    priority = 1000,
    config = function()
      -- vim.g["everforest_background"] = "hard"
      -- vim.cmd.colorscheme "everforest"
    end,
  },
  {
    "navarasu/onedark.nvim",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('onedark').setup {
      style = 'warmer'
    }
    -- Enable theme
    require('onedark').load()
  end
  }
}
