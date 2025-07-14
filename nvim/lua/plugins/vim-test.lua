return {
  "vim-test/vim-test",
  keys = {
    { "<leader>t", desc = "Run nearest test" },
    { "<leader>T", desc = "Run test file" },
    { "<leader>lt", desc = "Run last test" },
  },
  config = function()
    --- -----------------------------
    --- python options
    --- -----------------------------
    vim.g["test#python#pytest#options"] = "-W ignore"

    --- -----------------------------
    --- JavaScript/TypeScript options
    --- -----------------------------
    vim.cmd [[
      let g:test#custom_filetypes = {'typescriptreact': 'typescript'}
    ]]
    
    -- Add .test.tsx and other patterns
    vim.g["test#typescript#file_patterns"] = {
      "_spec.ts$",
      "_test.ts$",
      "_spec.tsx$",
      "_test.tsx$",
      "%.spec.ts$",
      "%.test.ts$",
      "%.spec.tsx$",
      "%.test.tsx$",
    }
    vim.g["test#javascript#file_patterns"] = vim.g["test#typescript#file_patterns"]

    -- Cache for the detected runner (per project)
    local cached_runner = nil

    -- Dynamic runner selection function that runs only once
    local function get_dynamic_runner()
      -- Return cached runner if already determined
      if cached_runner then
        return cached_runner
      end

      -- Check if Vitest is installed, and return it if found
      local vitest = vim.fn.system "npx --no-install vitest --version 2>/dev/null"
      if vim.v.shell_error == 0 and vitest ~= "" then
        cached_runner = "vitest"
        vim.notify("Test runner detected: Vitest", vim.log.levels.INFO)
        return cached_runner
      end

      -- If Vitest is not found, check for Jest
      local jest = vim.fn.system "npx --no-install jest --version 2>/dev/null"
      if vim.v.shell_error == 0 and jest ~= "" then
        cached_runner = "jest"
        vim.notify("Test runner detected: Jest", vim.log.levels.INFO)
        return cached_runner
      end

      -- Fallback to jest even if not found
      cached_runner = "jest"
      vim.notify("No test runner found, falling back to Jest", vim.log.levels.WARN)
      return cached_runner
    end

    -- Set default runners (lightweight setup)
    vim.g["test#javascript#runner"] = "jest"
    vim.g["test#typescript#runner"] = "jest"
    
    -- Test runner function that handles dynamic detection
    local function run_test_with_dynamic_runner(test_cmd)
      local runner = get_dynamic_runner()
      vim.g["test#javascript#runner"] = runner
      vim.g["test#typescript#runner"] = runner
      vim.cmd(test_cmd)
    end

    -- Keymaps (only set up when plugin loads)
    vim.keymap.set("n", "<leader>t", function()
      run_test_with_dynamic_runner("TestNearest")
    end, { desc = "Run nearest test" })
    
    vim.keymap.set("n", "<leader>T", function()
      run_test_with_dynamic_runner("TestFile")
    end, { desc = "Run test file" })
    
    vim.keymap.set("n", "<leader>lt", function()
      run_test_with_dynamic_runner("TestLast")
    end, { desc = "Run last test" })
  end,
}
