vim.g.mapleader = ","
vim.g.maplocalleader = ","

local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "e", "<cmd>edit %:h<CR>", { desc = "[E]dit the directory of the current file" })

vim.api.nvim_set_keymap(
  "n",
  "#",
  [[:let @/='\<' . expand('<cword>') . '\>'<CR>:set hlsearch<CR>]],
  { noremap = true, silent = true }
)

map({ "n", "v" }, "<C-a>", "<Nop>", { desc = "Deactivate Ctrl-a in normal and visual modes" })
map({ "n", "v" }, "<C-x>", "<Nop>", { desc = "Deactivate Ctrl-x in normal and visual modes" })

vim.api.nvim_create_user_command("W", "w", {})

map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
