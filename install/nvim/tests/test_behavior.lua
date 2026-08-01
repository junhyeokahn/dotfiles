local helpers = require "helpers"

local child = helpers.new_child()
local T = helpers.new_set(child)
local eq = MiniTest.expect.equality

T["conform formats lua with stylua"] = function()
  child.lua [[
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "local    x   =    1" })
    vim.bo.filetype = "lua"
    require("conform").format { bufnr = 0, async = false, lsp_format = "never" }
  ]]
  eq(child.lua_get "vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]", "local x = 1")
end

T["conform formats python with yapf"] = function()
  child.lua [[
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "x   =    1" })
    vim.bo.filetype = "python"
    require("conform").format { bufnr = 0, async = false, lsp_format = "never" }
  ]]
  eq(child.lua_get "vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]", "x = 1")
end

T["harpoon list round-trips"] = function()
  child.lua [[
    _G.h = require("harpoon")
    vim.cmd.edit("install/nvim/flake.nix")
    _G.h:list():add()
  ]]
  eq(child.lua_get "_G.h:list():length()", 1)
  eq(child.lua_get '_G.h:list():get(1).value ~= nil', true)
end

T["treesitter highlights a cpp buffer"] = function()
  child.lua [[
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "int main() { return 0; }" })
    vim.bo.filetype = "cpp"
    local parser = vim.treesitter.get_parser(0, "cpp")
    local tree = parser:parse()[1]
    local query = vim.treesitter.query.get("cpp", "highlights")
    _G.captures = 0
    for _ in query:iter_captures(tree:root(), 0, 0, -1) do
      _G.captures = _G.captures + 1
    end
  ]]
  MiniTest.expect.no_equality(child.lua_get "_G.captures", 0)
end

T["oil lists a directory"] = function()
  child.lua [[ vim.cmd.edit("oil://" .. vim.fn.getcwd() .. "/install/nvim") ]]
  child.lua [[ vim.wait(3000, function() return vim.api.nvim_buf_line_count(0) > 1 end) ]]
  local lines = child.lua_get "table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\\n')"
  eq(lines:find "flake.nix" ~= nil, true)
end

T["lua_ls attaches and completes"] = function()
  child.lua [[
    vim.cmd.edit("install/nvim/config/lua/config/options.lua")
    vim.bo.filetype = "lua"
  ]]
  local attached = child.lua_get [[
    vim.wait(30000, function()
      return #vim.lsp.get_clients { bufnr = 0, name = "lua_ls" } > 0
    end, 200)
  ]]
  eq(attached, true)

  -- A single completion request fired right after attach reliably comes
  -- back empty: lua_ls answers immediately from whatever state it has, and
  -- learning that `have_nerd_font`/`clipboard` are members of vim.g takes a
  -- workspace-wide scan of this repo's own lua files that (measured here)
  -- finishes ~10s after attach, not before. So this polls the same request
  -- instead of waiting on one in-flight callback - the assertion below is
  -- unchanged, only how long we give the server to actually be ready is.
  child.lua [[
    _G.items = {}
    vim.wait(20000, function()
      local items
      vim.lsp.buf_request(0, "textDocument/completion", {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = { line = 0, character = 6 },
      }, function(_, result)
        items = result and (result.items or result) or {}
      end)
      vim.wait(1000, function() return items ~= nil end, 50)
      _G.items = items or {}
      return #_G.items > 0
    end, 300)
  ]]
  MiniTest.expect.no_equality(child.lua_get "#_G.items", 0)
end

return T
