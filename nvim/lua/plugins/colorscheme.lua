return {
  {
  "rebelot/kanagawa.nvim",
  -- lazy wont execute this function until plugin has been installed
  config = function()
    --vim.cmd.colorscheme("kanagawa-dragon")
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

