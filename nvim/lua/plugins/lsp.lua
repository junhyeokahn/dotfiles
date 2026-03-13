local capabilities = vim.lsp.protocol.make_client_capabilities()

do
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end
end

vim.diagnostic.config {
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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local keymap = vim.keymap.set
    local opts = { silent = true, buffer = ev.buf }

    local function opt(desc, extra)
      return vim.tbl_extend("force", opts, { desc = desc }, extra or {})
    end

    keymap("n", "grn", vim.lsp.buf.rename, opt "Rename")

    keymap({ "n", "x" }, "gra", function()
      require("fzf-lua").lsp_code_actions()
    end, opt "Code Action")

    keymap("n", "gri", function()
      require("fzf-lua").lsp_implementations()
    end, opt "Go to implementation")

    keymap("n", "grr", function()
      require("fzf-lua").lsp_references()
    end, opt "Go to references")

    keymap("n", "gd", function()
      require("fzf-lua").lsp_definitions()
    end, opt "Go to definition")

    keymap("n", "gh", "<cmd>LspClangdSwitchSourceHeader<CR>", opt "Go to header")

    keymap("n", "grd", function()
      require("fzf-lua").lsp_document_diagnostics()
    end, opt "Open diagnostics")

    keymap("n", "K", function()
      vim.lsp.buf.hover {
        border = "single",
        max_height = 30,
        max_width = 120,
      }
    end, opt "Hover")

    keymap("n", "grs", function()
      require("fzf-lua").lsp_document_symbols()
    end, opt "Document Symbols")

    keymap("n", "grS", function()
      require("fzf-lua").lsp_workspace_symbols()
    end, opt "Workspace Symbols")

    keymap("n", "grh", function()
      local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = ev.buf }
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
    end, opt "Toggle Inlay hints")
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
      python = {
        venvPath = vim.fn.expand "~" .. "/venv",
      },
      basedpyright = {
        disableOrganizeImports = true,
        analysis = {
          autoSearchPaths = true,
          autoImportCompletions = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "standard",
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

  clangd = {
    cmd = {
      "clangd",
      "-j=2",
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
  server_config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})

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
  complete = function()
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
    vim.notify "Servers are stopped but havent been restarted"
    return
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
end, { desc = "Restart all the language client(s) attached to the current buffer" })

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.vsplit(vim.lsp.log.get_filename())
end, { desc = "Get all the lsp logs" })

vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd "silent checkhealth vim.lsp"
end, { desc = "Get all the information about all LSP attached" })
