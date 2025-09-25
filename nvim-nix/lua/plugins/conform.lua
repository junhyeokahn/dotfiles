require("conform").setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = {}
    return {
      timeout_ms = 1000,
      lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
    }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_fix", "ruff_format" },
  },
}

-- Set up keybinding
vim.keymap.set("", "<leader>f", function()
  require("conform").format { async = true, lsp_fallback = true }
end, { desc = "[F]ormat buffer" })