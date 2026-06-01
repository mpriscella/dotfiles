return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  lazy = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.opt.termguicolors = true

    require('nvim-tree').setup {
      -- Don't let nvim-tree take over the window when opening a directory;
      -- we handle that ourselves below so the tree sits next to a scratch buffer.
      hijack_directories = {
        enable = false,
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
        custom = { '^\\.direnv$', '^\\.git$', '^\\.jj$' },
      },
      view = {
        side = 'right',
      },
    }

    -- When nvim is launched with a directory argument (e.g. opening a folder
    -- from yazi), open the tree on the right next to an empty scratch buffer.
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function(data)
        if vim.fn.isdirectory(data.file) ~= 1 then
          return
        end

        vim.cmd.cd(data.file)

        -- Replace the directory buffer with a scratch buffer in the main window.
        local scratch = vim.api.nvim_create_buf(true, true)
        vim.api.nvim_win_set_buf(0, scratch)
        pcall(vim.api.nvim_buf_delete, data.buf, { force = true })

        require('nvim-tree.api').tree.open { focus = false }
      end,
    })
  end,
  keys = {
    {
      '\\',
      function()
        vim.cmd 'NvimTreeToggle'
      end,
      desc = 'Toggle Explorer',
    },
  },
}
