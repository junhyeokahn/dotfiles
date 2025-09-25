vim.g.nixcats_init_loaded = true

-- Core configuration
require("options")
require("keymaps")
require("snippets")

-- Setup plugins
require("guess-indent").setup()
require("Comment").setup()
require("plugins.gitsigns")
require("plugins.vim-visual-multi")
require("plugins.fzf-lua")
require("plugins.lsp")
require("plugins.conform")
require("plugins.nvim-cmp")
require("plugins.kanagawa")
require("plugins.todo-comments")
require("plugins.mini")
require("plugins.nvim-treesitter")
require("plugins.autopairs")
require("plugins.neoscroll")
require("plugins.flash")
require("plugins.oil")
require("plugins.harpoon")
require("plugins.git-blame")