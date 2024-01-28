-- Documentation can be found here https://neovim.io/doc/user/lua-guide.html.
-- Help can also be found by running `:help lua`.
-- Neovim uses Lua 5.1. Reference manual can be found here: https://www.lua.org/manual/5.1

-- Initialize lazy.nvim package manager.
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ChangeBackground changes the background mode based on macOS's `Appearance
-- setting.
-- Should only run on Darwin. Maybe a system check to `uname`? How to differentiate between windows and mac.
local function change_background()
  local m = vim.fn.system("defaults read -g AppleInterfaceStyle")
  m = m:gsub("%s+", "") -- trim whitespace
  if m == "Dark" then
    vim.o.background = "dark"
  else
    vim.o.background = "light"
  end
end

require("lazy").setup({})

----------------
--- SETTINGS ---
----------------

vim.g.mapleader = ','

----------------
-- various.txt -
----------------

vim.opt.number = true -- Show line numbers.

----------------
-- options.txt -
----------------

vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.linebreak = true
vim.opt.relativenumber = false -- Show the line number relative to the line with the cursor in front of each line.
vim.opt.smartindent = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.clipboard = "unnamed,unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true

----------------
--- MAPPINGS ---
----------------

vim.keymap.set('n', '<Leader>t', ':tabnew<cr>')
vim.keymap.set('n', '<Leader>w', ':tabclose<cr>')

-- Search mappings: These will make it so that going to the next one in a
-- search will center on the line it's found in.
vim.keymap.set('n', 'n', 'nzzzv', {noremap = true})
vim.keymap.set('n', 'N', 'Nzzzv', {noremap = true})
