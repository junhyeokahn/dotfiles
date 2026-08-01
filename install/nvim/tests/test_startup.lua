local helpers = require "helpers"

local child = helpers.new_child()
local T = helpers.new_set(child)
local eq = MiniTest.expect.equality

-- init.lua uses bare `require` with no pcall. A plugin whose setup{} throws
-- prints an error and lets startup continue, so "nvim started" proves nothing.
-- These are the assertions that actually catch a half-applied config.
T["startup produces no errors"] = function()
  eq(child.lua_get "vim.v.errmsg", "")
  eq(child.cmd_capture "messages", "")
end

-- LuaJIT leaves a non-nil sentinel in package.loaded while a module is loading,
-- even if the loader throws. This detects omitted `require` statements that silently
-- corrupt the config, but cannot pinpoint which module broke — it passes outright
-- if the terminal module (plugins.zk) throws. The "startup produces no errors" test
-- is the reliable guard against throwing modules.
T["every config module loaded"] = function()
  local modules = {
    "config.options",
    "config.keymaps",
    "config.autocmds",
    "plugins",
    "plugins.colorscheme",
    "plugins.editing",
    "plugins.navigation",
    "plugins.git",
    "plugins.syntax",
    "plugins.markdown",
    "plugins.completion",
    "plugins.lsp",
    "plugins.zk",
  }
  for _, mod in ipairs(modules) do
    eq({ mod, child.lua_get("package.loaded[...] ~= nil", { mod }) }, { mod, true })
  end
end

T["leader is set"] = function()
  eq(child.lua_get "vim.g.mapleader", ",")
end

T["colorscheme applied"] = function()
  eq(child.lua_get "vim.g.colors_name", "kanagawa")
end

T["options applied"] = function()
  eq(child.lua_get "vim.o.winborder", "rounded")
  eq(child.lua_get "vim.o.laststatus", 3)
  eq(child.lua_get "vim.o.signcolumn", "yes")
  eq(child.lua_get "vim.o.smartcase", true)
  eq(child.lua_get "vim.o.showmode", false)
end

return T
