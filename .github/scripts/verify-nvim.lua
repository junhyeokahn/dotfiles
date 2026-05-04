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

print("verify-nvim: ok")
