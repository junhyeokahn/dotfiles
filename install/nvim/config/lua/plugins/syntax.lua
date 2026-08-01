require("todo-comments").setup({
  signs = false,
})

local ts = require("nvim-treesitter")

ts.setup({})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local ft = vim.bo[args.buf].filetype

    local ok = pcall(vim.treesitter.start, args.buf, ft)
    if not ok then
      return
    end

    if ft ~= "ruby" then
      vim.bo[args.buf].indentexpr = "nvim_treesitter#indent()"
    end
  end,
})
