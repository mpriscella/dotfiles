return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    ---@type snacks.indent.Config|{}
    indent = { enabled = true },
    ---@type snacks.notifier.Config|{}
    notifier = { enabled = true, },
    ---@type snacks.picker.Config|{}
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true, exclude = { ".git" } },
        grep = { hidden = true, exclude = { ".git" } },
      },
    },
    ---@type snacks.quickfile.Config|{}
    quickfile = { enabled = true },
    ---@type snacks.statuscolumn.Config|{}
    statuscolumn = { enabled = true },
    ---@type snacks.words.Config|{}
    words = { enabled = true },
  },
  keys = {
    { '<leader>fds', function() Snacks.picker.lsp_symbols() end,    desc = '[F]ind [d]ocument [s]ymbols' },
    { '<leader>ff',  function() Snacks.picker.files() end,          desc = '[F]ind [f]iles' },
    { '<leader>fh',  function() Snacks.picker.help() end,           desc = '[F]ind [h]elp tags' },
    { '<leader>fr',  function() Snacks.picker.lsp_references() end, desc = '[F]ind [r]eferences' },
    { '<leader>gs',  function() Snacks.picker.grep() end,           desc = '[G]rep [s]tring' },
    { '<leader>km',  function() Snacks.picker.keymaps() end,        desc = '[K]ey [m]aps' },
    { '<leader>sd',  function() Snacks.picker.diagnostics() end,    desc = '[S]earch [d]iagnostics' },
    { '<leader>st',  function() Snacks.picker.treesitter() end,     desc = '[S]earch [t]reesitter' },
  },
}
