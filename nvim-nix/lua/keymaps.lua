vim.g.mapleader = ","
vim.g.maplocalleader = ","

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>e", ":e %:h", { desc = "[E]dit the directory of the current file" })
vim.api.nvim_set_keymap(
  "n",
  "#",
  [[:let @/='\<'.expand('<cword>').'\>'<CR>:set hlsearch<CR>]],
  { noremap = true, silent = true }
)

vim.keymap.set({ "n", "v" }, "<C-a>", "<nop>", { desc = "Deactivate Ctrl-a in normal and visual modes" })
vim.keymap.set({ "n", "v" }, "<C-x>", "<nop>", { desc = "Deactivate Ctrl-x in normal and visual modes" })

vim.api.nvim_create_user_command("W", "w", {})

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
