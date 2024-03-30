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
    "nvim-lualine/lualine.nvim",
    enabled = not vim.g.vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup()
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = not vim.g.vscode,
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", "terraform", "go", "yaml", "jsonc" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },
  {
    'numToStr/Comment.nvim',
    lazy = false,
    config = function()
      require('Comment').setup()
    end
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end
  }
})


----------------
--- SETTINGS ---
----------------

if vim.g.vscode then
  vim.g.clipboard = vim.g.vscode_clipboard
else
  vim.opt.termguicolors = true
  vim.opt.mouse = "a"
  vim.opt.number = true         -- Show line numbers.
  vim.opt.relativenumber = true -- Show the line number relative to the line with the cursor in front of each line.
end

vim.opt.clipboard = "unnamed,unnamedplus"

vim.g.mapleader = ","

vim.opt.expandtab = true   -- Use spaces instead of tabs.
vim.opt.ignorecase = true  -- Ignore case when searching.
vim.opt.smartindent = true -- Autoindent when starting a new line.
vim.opt.shiftwidth = 2     -- Number of spaces per indent.
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Tabs.
vim.keymap.set("n", "<Leader>t", ":tabnew<CR>", { silent = true })
vim.keymap.set("n", "<Leader>w", ":tabclose<CR>", { silent = true })

-- Map <Leader>[1-9] to switch between open tabs.
for i = 1,9,1
do
  vim.keymap.set("n", string.format("<Leader>%d", i), string.format("%dgt<CR>", i), { noremap = true, silent = true })
end

vim.keymap.set("n", "<Leader>e", ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Search mappings: These will make it so that going to the next one in a
-- search will center on the line it's found in.
vim.keymap.set("n", "n", "nzzzv", { noremap = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true })

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Map Ctrl-(h|j|k|l) to move between panes.
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", { silent = true })
