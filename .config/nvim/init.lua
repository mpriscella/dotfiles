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

require("lazy").setup({
  {
    "iamcco/markdown-preview.nvim",
    enabled = not vim.g.vscode,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    "junegunn/fzf.vim",
    enabled = not vim.g.vscode
  },
  {
    "nvim-lualine/lualine.nvim",
    enabled = not vim.g.vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = not vim.g.vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end
  },
  {
    "tpope/vim-commentary",
    enabled = not vim.g.vscode
  },
  { "tpope/vim-sensible" },
  { "tpope/vim-surround" },
})

----------------
--- SETTINGS ---
----------------

if vim.g.vscode then
  -- VSCode extension
else
  -- ordinary Neovim
  vim.opt.termguicolors = true
  vim.opt.mouse = "a"
  vim.opt.number = true          -- Show line numbers.
  vim.opt.relativenumber = false -- Show the line number relative to the line with the cursor in front of each line.
end

vim.g.mapleader = ","

----------------
-- various.txt -
----------------


----------------
-- options.txt -
----------------

vim.opt.expandtab = true   -- Use spaces instead of tabs.
vim.opt.ignorecase = true  -- Ignore case when searching.
-- vim.opt.linebreak = true
vim.opt.smartindent = true -- Autoindent when starting a new line.
vim.opt.shiftwidth = 2     -- Number of spaces per indent.
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true

----------------
--- MAPPINGS ---
----------------

vim.keymap.set("n", "<Leader>t", ":tabnew<cr>")
vim.keymap.set("n", "<Leader>w", ":tabclose<cr>")

-- Search mappings: These will make it so that going to the next one in a
-- search will center on the line it's found in.
vim.keymap.set("n", "n", "nzzzv", { noremap = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true })




vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
