local helpers = require "helpers"

local child = helpers.new_child()
local T = helpers.new_set(child)
local eq = MiniTest.expect.equality

--- Assert every listed expression is a callable, naming the path on failure.
local function expect_functions(paths)
  for _, path in ipairs(paths) do
    eq({ path, child.lua_get("type(" .. path .. ")") }, { path, "function" })
  end
end

T["editing: plugin APIs"] = function()
  expect_functions {
    'require("conform").setup',
    'require("conform").format',
    'require("mini.ai").setup',
    'require("mini.surround").setup',
    'require("mini.statusline").setup',
    'require("mini.statusline").section_location',
    'require("guess-indent").setup',
    'require("Comment").setup',
    'require("neoscroll").setup',
  }
end

T["navigation: fzf-lua APIs"] = function()
  expect_functions {
    'require("fzf-lua").setup',
    'require("fzf-lua").register_ui_select',
    'require("fzf-lua").actions.file_edit_or_qf',
    'require("fzf-lua").help_tags',
    'require("fzf-lua").keymaps',
    'require("fzf-lua").files',
    'require("fzf-lua").grep_cword',
    'require("fzf-lua").live_grep',
    'require("fzf-lua").buffers',
    'require("fzf-lua").lines',
    'require("fzf-lua").treesitter',
    'require("fzf-lua").quickfix',
    'require("fzf-lua").git_status',
  }
end

T["navigation: lsp picker APIs"] = function()
  expect_functions {
    'require("fzf-lua").lsp_code_actions',
    'require("fzf-lua").lsp_implementations',
    'require("fzf-lua").lsp_references',
    'require("fzf-lua").lsp_definitions',
    'require("fzf-lua").lsp_document_diagnostics',
    'require("fzf-lua").lsp_document_symbols',
    'require("fzf-lua").lsp_workspace_symbols',
  }
end

T["navigation: flash and oil APIs"] = function()
  expect_functions {
    'require("flash").setup',
    'require("flash").jump',
    'require("flash").treesitter',
    'require("flash").remote',
    'require("flash").treesitter_search',
    'require("flash").toggle',
    'require("oil").setup',
    'require("oil").toggle_float',
  }
end

T["navigation: harpoon APIs"] = function()
  expect_functions {
    'require("harpoon").setup',
    'require("harpoon").ui.toggle_quick_menu',
    'require("harpoon"):list().add',
    'require("harpoon"):list().next',
    'require("harpoon"):list().prev',
    'require("harpoon"):list().select',
  }
end

T["completion: cmp and luasnip APIs"] = function()
  -- cmp.setup is `setmetatable({ global = ..., filetype = ..., ... }, { __call
  -- = ... })` in nvim-cmp's own source (lua/cmp/init.lua) -- a callable table,
  -- not a plain function. This is nvim-cmp's own long-standing multi-purpose
  -- setup design, not something the 0.11.1 -> 0.12.4 bump changed, and the
  -- config's own `cmp.setup { ... }` call in plugins/completion.lua works
  -- (proven by "startup produces no errors" passing). type()=="function"
  -- is the wrong test for callability here, so this one path is checked with
  -- vim.is_callable instead of folding it into expect_functions.
  eq(child.lua_get 'vim.is_callable(require("cmp").setup)', true)
  expect_functions {
    -- plugins/lsp.lua also pcalls this: `local ok, cmp_nvim_lsp = pcall(require,
    -- "cmp_nvim_lsp")`. Unlike zk.lua, a failed require there doesn't stop
    -- lsp.lua from running (no early return), so it can't be caught by a
    -- keymap check -- it silently just never merges cmp's capabilities into
    -- any LSP client, which is invisible to this test suite otherwise. This
    -- is a pure-Lua module (part of the cmp plugin family, no external
    -- binary), so asserting it loads is safe on a runner without the `zk`
    -- binary or any language server installed.
    'require("cmp_nvim_lsp").default_capabilities',
    'require("cmp").mapping.preset.insert',
    'require("cmp").mapping.select_next_item',
    'require("cmp").mapping.select_prev_item',
    'require("cmp").mapping.scroll_docs',
    'require("cmp").mapping.confirm',
    'require("cmp").config.window.bordered',
    'require("luasnip").config.setup',
    'require("luasnip").lsp_expand',
    'require("luasnip").expand_or_locally_jumpable',
    'require("luasnip").locally_jumpable',
    'require("luasnip").expand_or_jump',
    'require("luasnip").jump',
    'require("nvim-autopairs").setup',
    'require("nvim-autopairs.completion.cmp").on_confirm_done',
  }
end

T["completion: cmp.event is subscribable"] = function()
  eq(child.lua_get 'type(require("cmp").event.on)', "function")
end

-- A `do ... end` block that dies partway registers no keymap, so one key per
-- block is a cheap proof that each ran to completion.
T["keymaps registered"] = function()
  local keys = {
    { "s", "n" }, -- flash
    { "-", "n" }, -- oil
    { "<leader>sf", "n" }, -- fzf-lua
    { "<leader>ha", "n" }, -- harpoon
    { "<leader>f", "n" }, -- conform
    { "<leader>-", "n" }, -- oil float
    -- plugins/zk.lua opens with `local ok, zk = pcall(require, "zk"); if not
    -- ok then return end`. If the require ever breaks (e.g. zk-nvim renamed
    -- or dropped by a nixpkgs bump), that pcall swallows the error and the
    -- whole file returns early -- no keymaps, no error, nothing else in this
    -- suite notices (see test_startup.lua's "every config module loaded"
    -- comment). These map() calls are the last statements in the file, so
    -- any one of them being registered proves the require succeeded and the
    -- file ran to completion. This does not depend on the `zk` binary itself
    -- being on PATH (deliberately not bundled in the flake, see README) --
    -- zk.setup() and vim.keymap.set() are pure Lua/zk-nvim calls that don't
    -- shell out.
    { "<leader>zn", "n" }, -- zk: new note
    { "<leader>zo", "n" }, -- zk: open notes
    { "<leader>zz", "n" }, -- zk: open last modified note
    { "<leader>zm", "n" }, -- zk: new meeting note
    { "<leader>zd", "n" }, -- zk: open/create daily note
    { "<leader>zt", "n" }, -- zk: tags
  }
  for _, k in ipairs(keys) do
    local got = child.lua_get("vim.fn.maparg(...) ~= ''", { k[1], k[2] })
    eq({ k[1], got }, { k[1], true })
  end
end

T["bundled tools on PATH"] = function()
  local tools = {
    "stylua",
    "lua-language-server",
    "basedpyright",
    "bash-language-server",
    "clangd",
    "rg",
    "fd",
    "fzf",
    "yapf",
  }
  for _, t in ipairs(tools) do
    eq({ t, child.lua_get("vim.fn.executable(...)", { t }) }, { t, 1 })
  end
end

T["user commands defined"] = function()
  local commands = { "Oil", "LspStart", "LspStop", "LspRestart", "LspLog", "LspInfo" }
  for _, c in ipairs(commands) do
    eq({ c, child.lua_get("vim.fn.exists(...)", { ":" .. c }) }, { c, 2 })
  end
end

T["treesitter parsers available"] = function()
  local langs = {
    "bash", "cpp", "diff", "html", "lua", "luadoc",
    "markdown", "markdown_inline", "python", "vim", "vimdoc", "yaml",
  }
  for _, l in ipairs(langs) do
    local ok = child.lua_get("pcall(vim.treesitter.language.add, ...)", { l })
    eq({ l, ok }, { l, true })
  end
end

return T
