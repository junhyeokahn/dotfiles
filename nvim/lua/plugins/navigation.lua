local map = vim.keymap.set

do
  local fzf = require "fzf-lua"

  fzf.setup {
    files = {
      git_icon = false,
    },
    actions = {
      files = {
        true,
        ["ctrl-q"] = {
          fn = fzf.actions.file_edit_or_qf,
          prefix = "select-all+",
        },
      },
    },
    winopts = {
      border = "rounded",
    },
    hls = {
      border = "FloatBorder",
      preview_border = "FloatBorder",
      help_border = "FloatBorder",
    },
  }

  local keymaps = {
    { "<leader>sh", fzf.help_tags, "Help" },
    { "<leader>sk", fzf.keymaps, "Keymaps" },
    { "<leader>sf", fzf.files, "Files" },
    { "<leader>sw", fzf.grep_cword, "Current word" },
    { "<leader>sg", fzf.live_grep, "Live grep (--glob)" },
    { "<leader>sb", fzf.buffers, "Buffers" },
    { "<leader>s/", fzf.lines, "Buffer lines" },
    { "<leader>st", fzf.treesitter, "Treesitter symbol" },
    { "<leader>sq", fzf.quickfix, "Quickfix list" },
    { "<leader>gs", fzf.git_status, "Git status" },
    {
      "<leader>sn",
      function()
        fzf.files { cwd = vim.fn.stdpath "config" }
      end,
      "Search Neovim files",
    },
  }

  for _, km in ipairs(keymaps) do
    map("n", km[1], km[2], { desc = km[3] })
  end

  fzf.register_ui_select(function(_, items)
    local min_h, max_h = 0.60, 0.80
    local h = (#items + 4) / vim.o.lines

    if h < min_h then
      h = min_h
    elseif h > max_h then
      h = max_h
    end

    return {
      winopts = {
        height = h,
        width = 0.80,
        row = 0.40,
      },
    }
  end)
end

do
  require("flash").setup {}

  map({ "n", "x", "o" }, "s", function()
    require("flash").jump()
  end, { desc = "Flash" })

  map({ "n", "x", "o" }, "S", function()
    require("flash").treesitter()
  end, { desc = "Flash Treesitter" })

  map("o", "r", function()
    require("flash").remote()
  end, { desc = "Remote Flash" })

  map({ "o", "x" }, "R", function()
    require("flash").treesitter_search()
  end, { desc = "Treesitter Search" })

  map("c", "<C-s>", function()
    require("flash").toggle()
  end, { desc = "Toggle Flash Search" })
end

do
  _G.CustomOilBar = function()
    local path = vim.fn.expand "%"
    path = path:gsub("oil://", "")
    return " " .. vim.fn.fnamemodify(path, ":.")
  end

  require("oil").setup {
    columns = { "icon" },
    keymaps = {
      ["<C-s>"] = false,
      ["<C-l>"] = false,
      ["<C-h>"] = false,
      ["<C-t>"] = false,
      ["<C-p>"] = false,
      ["<C-v>"] = "actions.select_split",
    },
    win_options = {
      winbar = "%{v:lua.CustomOilBar()}",
    },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        local folder_skip = {
          "dev-tools.locks",
          "dune.lock",
          "_build",
        }
        return vim.tbl_contains(folder_skip, name)
      end,
    },
  }

  map("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
  map("n", "<leader>-", function()
    require("oil").toggle_float()
  end, { desc = "Open parent directory (float)" })
end

do
  local harpoon = require "harpoon"

  harpoon:setup {
    settings = {
      save_on_toggle = true,
    },
  }

  map("n", "<leader>ha", function()
    harpoon:list():add()
  end, { desc = "Add File" })

  map("n", "<leader>hl", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end, { desc = "Menu" })

  map("n", "<leader>hn", function()
    harpoon:list():next()
  end, { desc = "Next" })

  map("n", "<leader>hp", function()
    harpoon:list():prev()
  end, { desc = "Prev" })

  for i = 1, 5 do
    map("n", "<leader>h" .. i, function()
      harpoon:list():select(i)
    end, { desc = "File " .. i })
  end
end
