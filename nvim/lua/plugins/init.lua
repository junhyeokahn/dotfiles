vim.pack.add({
  { src = "https://github.com/NMAC427/guess-indent.nvim" },
  { src = "https://github.com/numToStr/Comment.nvim" },
  { src = "https://github.com/github/copilot.vim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/f-person/git-blame.nvim" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/folke/flash.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/mg979/vim-visual-multi", version = "master" },
  { src = "https://github.com/rebelot/kanagawa.nvim" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/karb94/neoscroll.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/zk-org/zk-nvim" },
}, {
  load = true,
  confirm = false,
})

require "plugins.colorscheme"
require "plugins.editing"
require "plugins.navigation"
require "plugins.git"
require "plugins.syntax"
require "plugins.markdown"
require "plugins.completion"
require "plugins.lsp"

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update plugins managed by vim.pack" })
