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
    -- conform's default timeout_ms is 1000. That's tight for the *first*
    -- ever process spawn out of a freshly restarted child: process creation
    -- plus python/yapf interpreter startup can eat most or all of a second
    -- before yapf has produced a single byte, with zero relation to whether
    -- yapf actually works. That's not a rare edge case here - pre_case
    -- restarts the child before every test (see helpers.lua), so this is a
    -- cold first spawn on every single run, local or CI, and CI runners in
    -- particular have no warm OS/page cache to shorten it further. Give the
    -- call a generous, bounded budget to absorb that one-time startup cost.
    -- This does not paper over a real formatter regression: if yapf is
    -- actually broken (bad output, crash, or a genuine hang) the buffer
    -- still won't equal the expected result below, and the timeout still
    -- bounds how long a truly hung process can block the suite.
    require("conform").format { bufnr = 0, async = false, lsp_format = "never", timeout_ms = 15000 }
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

  -- The check above only proves *some* completion came back, which is not
  -- proof of anything -- see the comment on commit 145bf89 for how this bit
  -- the suite before: without Lua.runtime/Lua.workspace.library, lua_ls has
  -- no idea `vim` exists, and completion at this exact position (right after
  -- "vim.g." in config/options.lua) fell back to scraping this repo's own
  -- lua files for the name "g" (`clipboard`, `mapleader`, `maplocalleader`)
  -- -- 3 non-empty items, zero `vim` knowledge, and the old count-only
  -- assertion passed anyway.
  --
  -- The obvious fix is "poll until `have_nerd_font` (a real vim.g member set
  -- by config/options.lua) shows up in the completion labels instead of
  -- until the list is merely non-empty" -- and that's what a first version
  -- of this test did. It was reverted: probing it directly against this
  -- flake's pinned lua-language-server (by editing this exact file/position
  -- through the real wrapped nvim, both with and without 145bf89, waiting up
  -- to 90s) showed completion at "vim.g." never offers `have_nerd_font` even
  -- with the fix correctly applied -- lua_ls resolves `vim.g`'s type from
  -- the runtime library as an index-signature-only table (any -> any, no
  -- static field list), so once it has real type info it stops doing the
  -- fallback name-scrape that produced `clipboard`/`mapleader` in the first
  -- place. Asserting on a completion label here would fail red even when
  -- everything is correct, which is exactly the false-negative Finding 2 was
  -- raised to prevent -- so this does not do that.
  --
  -- What IS a real, verified content signal: 145bf89's own commit message
  -- names the directly observable symptom -- "Undefined global `vim`" on
  -- every line that touches vim.*. Probing (same method as above, sampling
  -- vim.diagnostic.get(0) once a second) showed this is fast and stable: 25
  -- such diagnostics on this exact buffer by 1s after attach without the
  -- fix, 0 by 1s with it, unchanged for the next 20s in both cases -- unlike
  -- completion, it does not depend on the multi-second workspace-wide scan.
  --
  -- Two ways of turning that into "wait, then assert" were tried and
  -- rejected because they never fire on a correctly-fixed config (i.e. they
  -- ran out the full budget and reported false negatives): the
  -- vim.diagnostic-level DiagnosticChanged autocmd, which in practice
  -- doesn't fire here when there's nothing to report, and hooking the raw
  -- textDocument/publishDiagnostics handler, which here fired for several
  -- other files lua_ls happened to be background-diagnosing but never for
  -- this one within the budget. So this polls vim.diagnostic.get(0)
  -- directly instead, exiting the instant the bad diagnostic shows up
  -- (fast, correct red); if it never shows up in 5s -- 5x the measured
  -- worst case, and still well under this test's other budgets -- that's
  -- treated as a real, settled "no `vim`-undefined diagnostic", not an
  -- unsettled one.
  local clean = child.lua_get [[
    (function()
      local bad = false
      vim.wait(5000, function()
        for _, d in ipairs(vim.diagnostic.get(0)) do
          if d.message:find "Undefined global" and d.message:find "vim" then
            bad = true
            return true
          end
        end
        return false
      end, 100)
      return not bad
    end)()
  ]]
  eq(clean, true)
end

return T
