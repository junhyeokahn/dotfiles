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
      { "sh", fzf.help_tags,  "Help" },
      { "sk", fzf.keymaps,    "Keymaps" },
      { "sf", fzf.files,      "Files" },
      { "sw", fzf.grep_cword, "Current word" },
      { "sg", fzf.live_grep,  "Live grep" },
      { "sb", fzf.buffers,    "Buffers" },
      { "s/", fzf.lines,      "Buffer lines" },
      { "st", fzf.treesitter, "Treesitter symbol" },
      { "sq", fzf.quickfix,   "Quickfix list" },
      { "gs", fzf.git_status, "Git status" },
      {
        "sn",
        function()
          fzf.files { cwd = vim.fn.stdpath "config" }
        end,
        "Search Neovim files",
      },
    }

    for _, km in ipairs(keymaps) do
      vim.keymap.set("n", "<leader>" .. km[1], km[2], { desc = km[3] })
    end

    fzf.register_ui_select(function(_, items)
      local min_h, max_h = 0.60, 0.80
      local h = (#items + 4) / vim.o.lines
      if h < min_h then
        h = min_h
      elseif h > max_h then
        h = max_h
      end
      return { winopts = { height = h, width = 0.80, row = 0.40 } }
    end)
