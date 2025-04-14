local dap = require "dap"
local dapui = require "dapui"
local dap_virtual_text = require "nvim-dap-virtual-text"
local dap_vscode_js = require "dap-vscode-js"

vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

dap_virtual_text.setup()
dapui.setup()

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

local keymap = vim.keymap.set
keymap("n", "<leader>dd", "<cmd>lua require('dap').continue()<CR>", { noremap = true, silent = true })
keymap("n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<CR>", { noremap = true, silent = true })
keymap(
  "n",
  "<leader>dB",
  "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { noremap = true, silent = true }
)

keymap("n", "<leader>dr", "<cmd>lua require('dap').repl.toggle()<CR>", { noremap = true, silent = true })
keymap("n", "<leader>ds", "<cmd>lua require('dap').step_over()<CR>", { noremap = true, silent = true })
keymap("n", "<leader>di", "<cmd>lua require('dap').step_into()<CR>", { noremap = true, silent = true })
keymap("n", "<leader>do", "<cmd>lua require('dap').step_out()<CR>", { noremap = true, silent = true })

-- typescript setup
dap_vscode_js.setup {
  debugger_path = vim.fn.stdpath "data" .. "/site/pack/packer/opt/vscode-js-debug",
}

local jsOrTs = {
  "typescript",
  "javascript",
  "javascriptreact",
  "typescriptreact",
}

dap.adapters.node2 = {
  type = "executable",
  command = "node",
  args = { os.getenv "HOME" .. "/dev/microsoft/vscode-node-debug2/out/src/nodeDebug.js" },
}

for _, language in ipairs(jsOrTs) do
  dap.configurations[language] = {
    --debug single node files
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      args = { " ${file}" },
      sourceMaps = true,
      protocol = "inspector",
    },

    --debug vitest test
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Program (pwa-node with vitest)",
      cwd = vim.fn.getcwd(),
      program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
      args = { "run", "${file}" },
      autoAttachChildProcesses = true,
      smartStep = true,
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },

    --debug nodejs processes (make sure --inspect is appended when running)
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
      sourceMaps = true,
    },
    {
      name = "Launch",
      type = "node2",
      request = "launch",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
    {
      -- For this to work you need to make sure the node process is started with the `--inspect` flag.
      name = "Attach to process",
      type = "node2",
      request = "attach",
      processId = require("dap.utils").pick_process,
    },
    -- divider for launch.json configs
    {
      name = "----- launch.json configs -----",
      type = "",
      request = "launch",
    },
  }
end

local vscode = require "dap.ext.vscode"
vscode.load_launchjs(nil, {
  ["pwa-node"] = jsOrTs,
  ["node"] = jsOrTs,
})
