local ok, zk = pcall(require, "zk")
if not ok then
  return
end

local api = require("zk.api")
local uv = vim.uv or vim.loop

zk.setup({
  picker = "fzf_lua",
  lsp = {
    config = {
      cmd = { "zk", "lsp" },
      name = "zk",
      filetypes = { "markdown" },
    },
    auto_attach = {
      enabled = true,
    },
  },
})

local notebook_dir = vim.env.ZK_NOTEBOOK_DIR or (vim.fn.expand("$HOME") .. "/notebook")

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "zk" })
end

local function edit_abs_path(path)
  vim.schedule(function()
    vim.cmd.edit(vim.fn.fnameescape(path))
  end)
end

local function new_default_note()
  local title = vim.fn.input("Title: ")
  if title == nil or title == "" then
    return
  end

  zk.new({
    title = title,
  })
end

local function open_notes_picker()
  zk.edit(
    {
      sort = { "modified-" },
    },
    {
      title = "Zk Notes",
    }
  )
end

local function open_last_modified_note()
  api.list(notebook_dir, {
    select = { "path" },
    limit = 1,
    sort = { "modified-" },
  }, function(err, notes)
    if err then
      notify("Failed to list notes: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    if not notes or vim.tbl_isempty(notes) then
      notify("No zk notes found")
      return
    end

    edit_abs_path(notebook_dir .. "/" .. notes[1].path)
  end)
end

local function new_meeting_note()
  local attendees = vim.fn.input("Attendees: ")
  if attendees == nil or attendees == "" then
    return
  end

  zk.new({
    group = "meeting",
    dir = "meeting",
    extra = {
      attendees = attendees,
    },
  })
end

local function open_or_create_daily_note()
  local today = os.date("%Y-%m-%d")
  local daily_path = notebook_dir .. "/daily/" .. today .. ".md"

  if vim.fn.filereadable(daily_path) == 1 then
    edit_abs_path(daily_path)
    return
  end

  zk.new({
    group = "daily",
    dir = "daily",
    date = "today",
  })
end

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>zn", new_default_note, vim.tbl_extend("force", opts, {
  desc = "zk: new note",
}))

map("n", "<leader>zo", open_notes_picker, vim.tbl_extend("force", opts, {
  desc = "zk: open notes",
}))

map("n", "<leader>zz", open_last_modified_note, vim.tbl_extend("force", opts, {
  desc = "zk: open last modified note",
}))

map("n", "<leader>zm", new_meeting_note, vim.tbl_extend("force", opts, {
  desc = "zk: new meeting note",
}))

map("n", "<leader>zd", open_or_create_daily_note, vim.tbl_extend("force", opts, {
  desc = "zk: open/create daily note",
}))

map("n", "<leader>zt", "<Cmd>ZkTags<CR>", opts)
