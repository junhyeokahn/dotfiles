-- Entry point. `vim.g.nvim_tests_dir` is set by the flake app.
local dir = vim.g.nvim_tests_dir
assert(dir, "vim.g.nvim_tests_dir not set - run via `nix run ./install/nvim#test`")

package.path = dir .. "/?.lua;" .. package.path

require("mini.test").setup {
  collect = {
    find_files = function()
      return vim.fn.globpath(dir, "test_*.lua", true, true)
    end,
  },
}

-- MiniTest.collect() re-raises (via `error`) any failure while sourcing a
-- test file (e.g. a broken top-level `assert` in a shared helper), and
-- MiniTest.run() does not guard that call. Left unguarded, nvim prints the
-- error (E5113) and then just sits there in headless mode instead of exiting
-- nonzero, turning a bootstrap bug into a CI hang. Guard it ourselves.
local ok, err = pcall(MiniTest.run)

if not ok then
  vim.api.nvim_err_writeln("nvim-test: bootstrap error: " .. tostring(err))
  vim.cmd "cquit 1"
end

-- MiniTest.run() calls `cquit 0`/`cquit 1` itself (via the stdout reporter's
-- `finish` hook) as soon as at least one case was collected, for both the
-- passing and failing case, and that never returns control here. So reaching
-- this point means zero cases were collected - e.g. the glob or tests dir
-- resolved wrong - which mini.test would otherwise treat as a vacuous pass.
-- Refuse that instead of exiting 0 having tested nothing.
local all_cases = MiniTest.current.all_cases
if all_cases == nil or #all_cases == 0 then
  vim.api.nvim_err_writeln "nvim-test: collected 0 test cases - refusing to report success"
  vim.cmd "cquit 1"
end

vim.cmd "qall!"
