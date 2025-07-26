local M = {}

function M.setup()
  require("harpoon").setup {
    global_settings = {
      mark_branch = true
    }
  }
  require("telescope").load_extension "harpoon"
end

return M
