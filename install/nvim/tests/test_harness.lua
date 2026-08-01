local helpers = require "helpers"

local child = helpers.new_child()
local T = helpers.new_set(child)
local eq = MiniTest.expect.equality

T["child loads the real config"] = function()
  eq(child.lua_get "vim.g.mapleader", ",")
end

T["child has plugins on runtimepath"] = function()
  eq(child.lua_get 'pcall(require, "fzf-lua")', true)
end

T["child startup is error-free"] = function()
  eq(child.lua_get "vim.v.errmsg", "")
  eq(child.cmd_capture "messages", "")
end

return T
