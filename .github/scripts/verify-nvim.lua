local plugins = {
  "fzf-lua",
  "oil",
  "harpoon",
  "cmp",
  "conform",
  "flash",
  "gitsigns",
  "todo-comments",
  "render-markdown",
}

for _, mod in ipairs(plugins) do
  local ok, err = pcall(require, mod)
  if not ok then
    io.stderr:write("FAIL plugin " .. mod .. ": " .. tostring(err) .. "\n")
    vim.cmd("cquit 1")
  end
end

local tools = {
  "stylua",
  "lua-language-server",
  "basedpyright",
  "bash-language-server",
  "clangd",
  "rg",
  "fd",
  "fzf",
}

for _, t in ipairs(tools) do
  if vim.fn.executable(t) == 0 then
    io.stderr:write("FAIL tool not on PATH: " .. t .. "\n")
    vim.cmd("cquit 1")
  end
end

local config_checks = {
  { "mapleader", function() return vim.g.mapleader == "," end },
  { ":Oil command", function() return vim.fn.exists(":Oil") == 2 end },
  { "kanagawa colorscheme", function() return vim.g.colors_name == "kanagawa" end },
}

for _, check in ipairs(config_checks) do
  if not check[2]() then
    io.stderr:write("FAIL config check: " .. check[1] .. "\n")
    vim.cmd("cquit 1")
  end
end

print("verify-nvim: ok")
