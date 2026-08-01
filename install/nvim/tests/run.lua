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

MiniTest.run()

-- MiniTest calls `cquit 1` itself when anything fails, so reaching this line
-- means everything passed. Without an explicit quit the headless process hangs
-- forever on success.
vim.cmd "qall!"
