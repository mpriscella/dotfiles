return {
  'OXY2DEV/markview.nvim',
  lazy = false,
  ---@type mkv.config
  opts = {
    preview = {
      filetypes = { 'markdown', 'codecompanion' },
      ignore_buftypes = {},
      hybrid_modes = { 'i', 'n', 'v' },
    },
  },
}
