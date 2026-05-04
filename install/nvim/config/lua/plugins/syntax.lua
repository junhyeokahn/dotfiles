require("todo-comments").setup({
  signs = false,
})

local ts = require("nvim-treesitter")
local parsers = {
  "bash",
  "cpp",
  "diff",
  "html",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "vim",
  "vimdoc",
  "yaml",
}

ts.setup({})

vim.api.nvim_create_autocmd("FileType", {
  pattern = parsers,
  callback = function(args)
    local ft = vim.bo[args.buf].filetype

    local ok = pcall(vim.treesitter.language.add, ft)
    if not ok then
      return
    end

    vim.treesitter.start(args.buf, ft)

    if ft ~= "ruby" then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
