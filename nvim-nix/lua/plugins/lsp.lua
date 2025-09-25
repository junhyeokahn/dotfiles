local config = {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "single",
    source = "always",
    header = "",
    prefix = "",
    suffix = "",
  },
}
vim.diagnostic.config(config)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- All the keymaps
    -- stylua: ignore start
    local keymap = vim.keymap.set
    local lsp = vim.lsp
    local fzf = require "fzf-lua"
    local opts = { silent = true }
    local function opt(desc, others)
      return vim.tbl_extend("force", opts, { desc = desc }, others or {})
    end
    keymap("n", "grn", lsp.buf.rename, opt("Rename"))
    keymap("n", "gra", fzf.lsp_code_actions, opt("Code Action"))
    keymap("n", "gri", fzf.lsp_implementations, opt("Go to implementation"))
    keymap("n", "grr", fzf.lsp_references, opt("Go to References"))
    keymap("n", "gd", fzf.lsp_definitions, opt("Go to definition"))
    keymap("n", "gh", ":LspClangdSwitchSourceHeader<CR>", opt("Go to header"))
    keymap("n", "grd", fzf.lsp_document_diagnostics, opt("Open diagnostics"))
    keymap({ "n", "i" }, "<C-S>", function() lsp.buf.signature_help({ border = "single" }) end, opts)
    keymap("n", "K", function() lsp.buf.hover({ border = "single", max_height = 30, max_width = 120 }) end,
      opt("Toggle hover"))
    keymap("n", "grs", fzf.lsp_document_symbols, opt("Doument Symbols"))
    keymap("n", "grS", fzf.lsp_workspace_symbols, opt("Workspace Symbols"))
    keymap("n", "grh", function() lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled({})) end,
      opt("Toggle Inlayhints"))
  end,
})

local servers = {
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".git", vim.uv.cwd() },
    settings = {
      Lua = {
        telemetry = {
          enable = false,
        },
      },
    },
  },

  basedpyright = {
    name = "basedpyright",
    filetypes = { "python" },
    cmd = { "basedpyright-langserver", "--stdio" },
    settings = {
      basedpyright = {
        disableOrganizeImports = true,
        analysis = {
          autoSearchPaths = true,
          autoImportCompletions = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "basic",
          inlayHints = {
            variableTypes = true,
            callArgumentNames = true,
            functionReturnTypes = true,
            genericTypes = false,
          },
        },
      },
    },
  },

  ruff = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    init_options = {
      settings = {
        args = {},
      },
    },
  },

  clangd = {
    cmd = {
      "clangd",
      "-j=" .. 2,
      "--background-index",
      "--clang-tidy",
      "--inlay-hints",
      "--fallback-style=llvm",
      "--all-scopes-completion",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--header-insertion-decorators",
      "--pch-storage=memory",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    root_markers = {
      "CMakeLists.txt",
      ".clangd",
      ".clang-tidy",
      ".clang-format",
      "compile_commands.json",
      "compile_flags.txt",
      "configure.ac",
      ".git",
      vim.uv.cwd(),
    },
  },

  bashls = {
    cmd = { "bash-language-server", "start" },
    filetypes = { "bash", "sh", "zsh" },
    root_markers = { ".git", vim.uv.cwd() },
    settings = {
      bashIde = {
        globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
      },
    },
  },
}

for server_name, server_config in pairs(servers) do
  vim.lsp.config(server_name, server_config)
  vim.lsp.enable(server_name)
end

vim.api.nvim_create_user_command("LspStart", function()
  vim.cmd.e()
end, { desc = "Starts LSP clients in the current buffer" })

vim.api.nvim_create_user_command("LspStop", function(opts)
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if opts.args == "" or opts.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ": stopped")
    end
  end
end, {
  desc = "Stop all LSP clients or a specific client attached to the current buffer.",
  nargs = "?",
  complete = function(_, _, _)
    local clients = vim.lsp.get_clients { bufnr = 0 }
    local client_names = {}
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)
    end
    return client_names
  end,
})

vim.api.nvim_create_user_command("LspRestart", function()
  local detach_clients = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    client:stop(true)
    if vim.tbl_count(client.attached_buffers) > 0 then
      detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
    end
  end
  local timer = vim.uv.new_timer()
  if not timer then
    return vim.notify "Servers are stopped but havent been restarted"
  end
  timer:start(
    100,
    50,
    vim.schedule_wrap(function()
      for name, client in pairs(detach_clients) do
        local client_id = vim.lsp.start(client[1].config, { attach = false })
        if client_id then
          for _, buf in ipairs(client[2]) do
            vim.lsp.buf_attach_client(buf, client_id)
          end
          vim.notify(name .. ": restarted")
        end
        detach_clients[name] = nil
      end
      if next(detach_clients) == nil and not timer:is_closing() then
        timer:close()
      end
    end)
  )
end, {
  desc = "Restart all the language client(s) attached to the current buffer",
})

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.vsplit(vim.lsp.log.get_filename())
end, {
  desc = "Get all the lsp logs",
})

vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd "silent checkhealth vim.lsp"
end, {
  desc = "Get all the information about all LSP attached",
})
