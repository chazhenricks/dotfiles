local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

local dap_ui_status_ok, dapui = pcall(require, "dapui")
if not dap_ui_status_ok then
  return
end

-----------------------------
-- JavaScript & TypeScript --
-----------------------------

local dap_vscode_js_ok, dap_js = pcall(require, "dap-vscode-js")
if not dap_vscode_js_ok then
  return
end

local jester_ok, jester = pcall(require, "jester")
if not jester_ok then
  return
end

local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
}

dap_js.setup {
  node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
  debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
  -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
  -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
  -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
}

for _, language in ipairs(js_based_languages) do
  require("dap").configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node)",
      cwd = vim.fn.getcwd(),
      args = { "${file}" },
      sourceMaps = true,
      protocol = "inspector",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node with ts-node)",
      cwd = vim.fn.getcwd(),
      runtimeArgs = { "--loader", "ts-node/esm" },
      runtimeExecutable = "node",
      args = { "${file}" },
      sourceMaps = true,
      protocol = "inspector",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node with deno)",
      cwd = vim.fn.getcwd(),
      runtimeArgs = { "run", "--inspect-brk", "--allow-all", "${file}" },
      runtimeExecutable = "deno",
      attachSimplePort = 9229,
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with jest)",
      cwd = vim.fn.getcwd(),
      runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest" },
      runtimeExecutable = "node",
      args = { "${file}", "--coverage", "false" },
      rootPath = "${workspaceFolder}",
      sourceMaps = true,
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with vitest)",
      cwd = vim.fn.getcwd(),
      program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
      args = { "--inspect-brk", "--threads", "false", "run", "${file}" },
      autoAttachChildProcesses = true,
      smartStep = true,
      console = "integratedTerminal",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with deno)",
      cwd = vim.fn.getcwd(),
      runtimeArgs = { "test", "--inspect-brk", "--allow-all", "${file}" },
      runtimeExecutable = "deno",
      attachSimplePort = 9229,
    },
    {
      type = "pwa-chrome",
      request = "attach",
      name = "Attach Program (pwa-chrome = { port: 9222 })",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      port = 9222,
      webRoot = "${workspaceFolder}",
    },
    {
      type = "node2",
      request = "attach",
      name = "Attach Program (Node2)",
      processId = require("dap.utils").pick_process,
    },
    {
      type = "node2",
      request = "attach",
      name = "Attach Program (Node2 with ts-node)",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
      port = 9229,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach Program (pwa-node)",
      cwd = vim.fn.getcwd(),
      processId = require("dap.utils").pick_process,
      skipFiles = { "<node_internals>/**" },
    },
  }
end

-- ## DAP `launch.json`
require("dap.ext.vscode").load_launchjs(nil, {
  ["pwa-node"] = {
    "javascript",
    "typescript",
  },
  ["node"] = {
    "javascript",
    "typescript",
  },
})

jester.setup {
  cmd = "npx jest -t '$result' -- $file", -- run command
  identifiers = { "test", "it" }, -- used to identify tests
  prepend = { "describe" }, -- prepend describe blocks
  expressions = { "call_expression" }, -- tree-sitter object used to scan for tests/describe blocks
  path_to_jest_run = "jest", -- used to run tests
  path_to_jest_debug = "./node_modules/.bin/jest", -- used for debugging
  terminal_cmd = ":vsplit | terminal", -- used to spawn a terminal for running tests, for debugging refer to nvim-dap's config
  dap = { -- debug adapter configuration
    type = "pwa-node",
    request = "launch",
    cwd = vim.fn.getcwd(),
    runtimeArgs = { "--inspect-brk", "$path_to_jest", "--no-coverage", "-t", "$result", "--", "$file" },
    args = { "--no-cache" },
    sourceMaps = false,
    protocol = "inspector",
    skipFiles = { "<node_internals>/**/*.js" },
    console = "integratedTerminal",
    port = 9229,
    disableOptimisticBPs = true,
  },
}

vscode.load_launchjs()

dapui.setup {
  expand_lines = true,
  icons = { expanded = "", collapsed = "", circular = "" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.33 },
        { id = "breakpoints", size = 0.17 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 0.33,
      position = "right",
    },
    {
      elements = {
        { id = "repl", size = 0.45 },
        { id = "console", size = 0.55 },
      },
      size = 0.27,
      position = "bottom",
    },
  },
  floating = {
    max_height = 0.9,
    max_width = 0.5, -- Floats will be treated as percentage of your screen.
    border = vim.g.border_chars, -- Border style. Can be 'single', 'double' or 'rounded'
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
}

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
