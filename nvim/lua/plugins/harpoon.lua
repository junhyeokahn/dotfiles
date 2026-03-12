return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    settings = {
      save_on_toggle = true,
    },
  },
  keys = function()
    local harpoon = require "harpoon"
    local keys = {
      {
        "<leader>ha",
        function()
          harpoon:list():add()
        end,
        desc = "Add File",
      },
      {
        "<leader>hl",
        function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Menu",
      },
      {
        "<leader>hn",
        function()
          harpoon:list():next()
        end,
        desc = "Next",
      },
      {
        "<leader>hp",
        function()
          harpoon:list():prev()
        end,
        desc = "Prev",
      },
    }
    for i = 1, 5 do
      table.insert(keys, {
        "<leader>h" .. i,
        function()
          harpoon:list():select(i)
        end,
        desc = "File " .. i,
      })
    end
    return keys
  end,
}
