return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require "telescope"
      telescope.setup {
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {},
          },
        },
      }

      telescope.load_extension "ui-select"

      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fd", function()
        builtin.find_files({
          prompt_title = "Select Directory",
          find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git", "--exclude", "node_modules" },
          attach_mappings = function(prompt_bufnr, map)
            local actions = require "telescope.actions"
            local action_state = require "telescope.actions.state"
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if selection then
                vim.schedule(function()
                  builtin.live_grep({ search_dirs = { selection.value } })
                end)
              end
            end)
            return true
          end,
        })
      end, {})
      vim.keymap.set("n", "<leader>fD", function()
        builtin.find_files({
          prompt_title = "Select Directory (node_modules included)",
          find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
          attach_mappings = function(prompt_bufnr, map)
            local actions = require "telescope.actions"
            local action_state = require "telescope.actions.state"
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if selection then
                vim.schedule(function()
                  builtin.live_grep({ search_dirs = { selection.value } })
                end)
              end
            end)
            return true
          end,
        })
      end, {})
      vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})
    end,
  },
}
