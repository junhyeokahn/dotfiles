require("todo-comments").setup {
  signs = false,
}

require("nvim-treesitter.install").prefer_git = true

require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "bash",
    "c",
    "diff",
    "html",
    "lua",
    "luadoc",
    "markdown",
    "vim",
    "vimdoc",
  },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "ruby" },
  },
  indent = {
    enable = true,
    disable = { "ruby" },
  },
}
