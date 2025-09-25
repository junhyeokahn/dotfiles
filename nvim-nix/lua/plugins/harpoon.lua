local harpoon = require "harpoon"

harpoon:setup {
  settings = {
    save_on_toggle = true,
  },
}

-- Keybindings
vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Add File" })
vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Menu" })
vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Next" })
vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Prev" })

for i = 1, 5 do
  vim.keymap.set("n", "<leader>h" .. i, function() harpoon:list():select(i) end, { desc = "File " .. i })
end