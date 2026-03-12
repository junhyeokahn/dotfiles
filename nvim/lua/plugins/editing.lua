local map = vim.keymap.set

require("guess-indent").setup {}
require("Comment").setup {}
require("mason").setup {}

require("conform").setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = {}

    return {
      timeout_ms = 500,
      lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
    }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "yapf" },
  },
}

map({ "n", "v" }, "<leader>f", function()
  require("conform").format {
    async = true,
    lsp_fallback = true,
  }
end, { desc = "[F]ormat buffer" })

require("mini.ai").setup {
  n_lines = 500,
}

require("mini.surround").setup()

local statusline = require "mini.statusline"
statusline.setup {
  use_icons = vim.g.have_nerd_font,
}

statusline.section_location = function()
  return "%2l:%-2v"
end

require("neoscroll").setup {}

vim.cmd [[
  nmap <C-Down> <Plug>(VM-Add-Cursor-Down)
  nmap <C-Up> <Plug>(VM-Add-Cursor-Up)
]]
