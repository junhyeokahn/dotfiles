-- Shared bootstrap for the nvim config test suite.
--
-- The nix wrapper starts Neovim with the config split across two mechanisms:
--   VIMINIT="lua dofile('/nix/store/<hash>-init.lua')"   (environment)
--   --cmd "set packpath^=/nix/store/<hash>-vim-pack-dir" (argv)
--   --cmd "set rtp^=<same>"                              (argv)
--
-- mini.test spawns child processes with a hardcoded `--clean`, which discards
-- both. So we recover them from the running parent and pass them to the child
-- explicitly. Without this a child has no mapleader and no plugins.

local M = {}

--- Reconstruct the argv a child needs in order to load the real config.
---@return string[]
function M.config_args()
  local viminit = vim.env.VIMINIT
  assert(viminit, "VIMINIT unset - tests must run under the nix-wrapped nvim")

  local init = viminit:match("dofile%(.([^'\"]+).%)")
  assert(init, "could not extract init path from VIMINIT: " .. viminit)

  local pack
  for _, p in ipairs(vim.opt.packpath:get()) do
    if p:match("vim%-pack%-dir") then
      pack = p
      break
    end
  end
  assert(pack, "no vim-pack-dir on packpath")

  return {
    "--cmd",
    "set packpath^=" .. pack,
    "--cmd",
    "set rtp^=" .. pack,
    "-u",
    init,
  }
end

--- A child Neovim preloaded with the args needed to reach the real config.
function M.new_child()
  local child = MiniTest.new_child_neovim()
  child.args = M.config_args()
  return child
end

--- A test set that gives every case a freshly restarted child.
function M.new_set(child)
  return MiniTest.new_set {
    hooks = {
      pre_case = function()
        child.restart(child.args)
      end,
      post_once = child.stop,
    },
  }
end

return M
