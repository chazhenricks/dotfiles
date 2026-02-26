return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "suketa/nvim-dap-ruby",
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    require("dapui").setup()
    require("dap-ruby").setup()

    local dap, dapui = require "dap", require "dapui"
    dap.configurations.ruby = {
      {
        type = "ruby",
        request = "launch",
        name = "Rails",
        program = "bundle",
        programArgs = { "exec", "rails", "s" },
        useBundler = true,
      },
    }
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.keymap.set("n", "<leader>dt", ":DapToggleBreakpoint<CR>")
    vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>")
    vim.keymap.set("n", "<leader>dx", ":DapTerminate<CR>")
    vim.keymap.set("n", "<leader>do", ":DapStepOver<CR>")
  end,
}
