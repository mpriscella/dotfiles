return {
  -- @see https://github.com/folke/snacks.nvim
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    ---@type snacks.dashboard.Config|{}
    dashboard = { enabled = true },
    ---@type snacks.explorer.Config|{}
    explorer = {
      enabled = true,
      replace_netrw = true,
    },
    ---@type snacks.indent.Config|{}
    indent = { enabled = true },
    ---@type snacks.input.Config|{}
    input = { enabled = true },
    ---@type snacks.lazygit.Config|{}
    lazygit = { enabled = true },
    ---@type snacks.picker.Config|{}
    picker = {
      enabled = true,
      sources = {
        ---@type snacks.picker.explorer.Config|{}
        explorer = {
          git_status_open = true,
          hidden = true,
          ignored = true,
          layout = { layout = { position = 'right' } },
        },
        ---@type snacks.picker.grep.Config|{}
        grep = {
          hidden = true,
        },
      },
    },
    ---@type snacks.notifier.Config|{}
    notifier = {
      enabled = true,
    },
    ---@type snacks.quickfile.Config|{}
    quickfile = { enabled = true },
    ---@type snacks.statuscolumn.Config|{}
    statuscolumn = { enabled = true },
    ---@type snacks.words.Config|{}
    words = { enabled = true },
  },
  keys = {
    {
      'gd',
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = '[G]oto [D]efinition',
    },
    {
      '<leader>sb',
      function()
        Snacks.picker.buffers()
      end,
      desc = '[S]earch [B]uffers',
    },
    {
      '<leader>sf',
      function()
        Snacks.picker.files {
          hidden = true,
        }
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = '[S]earch [G]rep',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>lg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Toggle Lazygit',
    },
    {
      '\\',
      function()
        Snacks.explorer()
      end,
      desc = 'Toggle Explorer',
    },
  },
}
