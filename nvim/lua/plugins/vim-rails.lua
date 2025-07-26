return {
  "tpope/vim-rails",
  lazy = false,
  ft = {
    "ruby", "eruby", "yaml", "yaml.eruby", "ruby.rails", "eruby.rails"
  },
  config = function()
    -- Rails.vim keymaps will go here
    vim.g.rails_projections = {
      ["app/controllers/*_controller.rb"] = {
        ["command"] = "controller",
        ["affinity"] = "controller",
        ["test"] = "spec/controllers/%s_controller_spec.rb",
        ["related"] = "app/models/%s.rb",
      },
      ["app/models/*.rb"] = {
        ["command"] = "model",
        ["affinity"] = "model",
        ["test"] = "spec/models/%s_spec.rb",
      }
    }
    
    -- Keymaps setup
    local keymap = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.silent = opts.silent ~= false
      vim.keymap.set(mode, lhs, rhs, opts)
    end
    
    -- Global Rails.vim shortcuts
    keymap("n", "<leader>ra", ":A<CR>", { desc = "Rails: Alternate file" })
    keymap("n", "<leader>rr", ":R<CR>", { desc = "Rails: Related file" })
    keymap("n", "<leader>rm", ":Emodel ", { desc = "Rails: Edit model" })
    keymap("n", "<leader>rc", ":Econtroller ", { desc = "Rails: Edit controller" })
    keymap("n", "<leader>rv", ":Eview ", { desc = "Rails: Edit view" })
    keymap("n", "<leader>rh", ":Ehelper ", { desc = "Rails: Edit helper" })
    keymap("n", "<leader>rl", ":Elayout ", { desc = "Rails: Edit layout" })
    keymap("n", "<leader>rj", ":Ejavascript ", { desc = "Rails: Edit JavaScript" })
    keymap("n", "<leader>rs", ":Estylesheet ", { desc = "Rails: Edit stylesheet" })
    keymap("n", "<leader>rp", ":Epolicy ", { desc = "Rails: Edit policy" })
    
    -- Rails specific commands
    keymap("n", "<leader>rgc", ":Generate controller ", { desc = "Rails: Generate controller" })
    keymap("n", "<leader>rgm", ":Generate model ", { desc = "Rails: Generate model" })
    keymap("n", "<leader>rgs", ":Generate scaffold ", { desc = "Rails: Generate scaffold" })
    keymap("n", "<leader>rc", ":Rails console<CR>", { desc = "Rails: Console" })
    keymap("n", "<leader>rs", ":Rails server<CR>", { desc = "Rails: Server" })
    keymap("n", "<leader>rd", ":Rails dbconsole<CR>", { desc = "Rails: DB Console" })
    keymap("n", "<leader>rt", ":Rails<CR>", { desc = "Rails: Run test" })
    keymap("n", "<leader>rti", ":.Rails<CR>", { desc = "Rails: Run test at line" })
  end,
  dependencies = {
    -- Optional but recommended dependencies
    { "tpope/vim-dispatch" },
    { "tpope/vim-bundler" },
  }
}
