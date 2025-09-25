-- When using Nix, parsers are provided by nvim-treesitter.withAllGrammars
-- So we disable auto_install and ensure_installed
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup {
  -- Don't install parsers (they're provided by Nix)
  ensure_installed = {},
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "ruby" },
  },
  indent = { enable = true, disable = { "ruby" } },
}