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

    -- default to unittest (vim-test calls it 'pyunit')
    local runner = "pyunit"
    vim.g["test#python#runner"] = runner

    -- run runners via uv so venv gets picked up automatically
    vim.g["test#python#pytest#executable"] = "uv run pytest"
    vim.g["test#python#pyunit#executable"] = "uv run python -m unittest"

    -- recognize both patterns for python tests across runners
    -- supports files named like test_foo.py and foo_test.py
    vim.g["test#python#pytest#file_pattern"] = "\\v(.*_test\\.py$|^test_.*\\.py$)"
    vim.g["test#python#pyunit#file_pattern"] = "\\v(.*_test\\.py$|^test_.*\\.py$)"

    -- dynamic python runner: default to unittest; if file imports/references pytest, use that
    local function buffer_contains_pytest()
      local ok, lines = pcall(vim.api.nvim_buf_get_lines, 0, 0, -1, false)
      if not ok or not lines then
        return false
      end
      for _, line in ipairs(lines) do
        if
          line:find("%f[%a]import%s+pytest%f[%A]") or
          line:find("%f[%a]from%s+pytest%s+import%f[%A]") or
          line:find("@%s*pytest%.") or
          line:find("%f[%a]pytest%.")
        then
          return true
        end
      end
      return false
    end

    local function get_dynamic_python_runner()
      -- Prefer pytest only when explicitly referenced in the buffer
      if buffer_contains_pytest() then
        return "pytest"
      end
      -- Otherwise default to unittest/pyunit
      return "pyunit"
    end

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

    -- Default (will be overridden dynamically)
    vim.g["test#javascript#runner"] = "jest"
    vim.g["test#typescript#runner"] = "jest"

    -- Per-project cache: root_dir -> "jest" | "vitest"
    local project_runner_cache = {}

    -- returns a table that contains the contents of a file
    local function read_file(path)
      local ok, data = pcall(vim.fn.readfile, path)
      if not ok or not data or #data == 0 then
        return nil
      end
      return table.concat(data, "\n")
    end

    local function find_package_json(start_dir)
      -- Prefer vim.fs.find (Neovim 0.9+), fallback to findfile
      if vim.fs and vim.fs.find then
        local hits = vim.fs.find("package.json", { upward = true, path = start_dir })
        return hits and hits[1] or nil
      else
        local found = vim.fn.findfile("package.json", start_dir .. ";")
        return found ~= "" and found or nil
      end
    end

    local function dirname(path)
      return vim.fn.fnamemodify(path, ":h")
    end

    local function detect_runner_from_package_json(pkg_json_path)
      local raw = read_file(pkg_json_path)
      if not raw then
        return nil
      end

      local ok, pkg = pcall(vim.json.decode or vim.fn.json_decode, raw)
      if not ok or type(pkg) ~= "table" then
        return nil
      end

      local scripts = pkg.scripts or {}

      -- 1) Look through any script whose NAME contains "test"
      for name, value in pairs(scripts) do
        if type(name) == "string" and type(value) == "string" then
          if name:lower():find("test", 1, true) then
            local v = value:lower()
            if v:find("vitest", 1, true) then
              return "vitest"
            end
            if v:find("jest", 1, true) then
              return "jest"
            end
          end
        end
      end

      -- 2) If no script match, peek at deps/devDeps as a hint
      local function has_dep(tbl, dep)
        return type(tbl) == "table" and tbl[dep] ~= nil
      end
      if has_dep(pkg.devDependencies, "vitest") or has_dep(pkg.dependencies, "vitest") then
        return "vitest"
      end
      if has_dep(pkg.devDependencies, "jest") or has_dep(pkg.dependencies, "jest") then
        return "jest"
      end

      return nil
    end

    local function probe_runner_binaries()
      -- last-resort: quick, no-install probes
      local vitest = vim.fn.system "npx --no-install vitest --version 2>/dev/null"
      if vim.v.shell_error == 0 and vitest ~= "" then
        return "vitest"
      end
      local jest = vim.fn.system "npx --no-install jest --version 2>/dev/null"
      if vim.v.shell_error == 0 and jest ~= "" then
        return "jest"
      end
      return nil
    end

    local function get_project_root_from_pkg(pkg_json_path)
      if not pkg_json_path then
        return vim.fn.getcwd()
      end
      return dirname(pkg_json_path)
    end

    local function get_dynamic_runner()
      -- Determine project based on nearest package.json to current buffer
      local buf_dir = vim.fn.expand "%:p:h"
      if buf_dir == "" then
        buf_dir = vim.fn.getcwd()
      end
      local pkg_json = find_package_json(buf_dir)
      local project_root = get_project_root_from_pkg(pkg_json)

      -- Cache per project root
      if project_runner_cache[project_root] then
        return project_runner_cache[project_root]
      end

      -- 1) Prefer package.json scripts (user’s requested heuristic)
      local from_pkg = pkg_json and detect_runner_from_package_json(pkg_json) or nil
      if from_pkg then
        project_runner_cache[project_root] = from_pkg
        vim.notify(("Test runner detected (%s): %s"):format(project_root, from_pkg), vim.log.levels.INFO)
        return from_pkg
      end

      -- 2) Fallback: probe binaries via npx --no-install
      local from_probe = probe_runner_binaries()
      if from_probe then
        project_runner_cache[project_root] = from_probe
        vim.notify(("Test runner detected (%s): %s"):format(project_root, from_probe), vim.log.levels.INFO)
        return from_probe
      end

      -- 3) Final fallback
      project_runner_cache[project_root] = "jest"
      vim.notify(("No test runner found for %s, falling back to Jest"):format(project_root), vim.log.levels.WARN)
      return "jest"
    end

    local function run_test_with_dynamic_runner(test_cmd)
      local ft = vim.bo.filetype
      if ft == "python" then
        vim.g["test#python#runner"] = get_dynamic_python_runner()
      else
        local runner = get_dynamic_runner()
        vim.g["test#javascript#runner"] = runner
        vim.g["test#typescript#runner"] = runner
      end
      vim.cmd(test_cmd)
    end

    -- Keymaps
    vim.keymap.set("n", "<leader>t", function()
      run_test_with_dynamic_runner "TestNearest"
    end, { desc = "Run nearest test" })

    vim.keymap.set("n", "<leader>T", function()
      run_test_with_dynamic_runner "TestFile"
    end, { desc = "Run test file" })

    vim.keymap.set("n", "<leader>lt", function()
      run_test_with_dynamic_runner "TestLast"
    end, { desc = "Run last test" })
  end,
}
