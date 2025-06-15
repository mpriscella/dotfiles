return {
  'mistricky/codesnap.nvim',
  build = 'make',
  keys = {
    { '<leader>cc', '<cmd>CodeSnap<cr>', mode = 'x', desc = 'Save selected code snapshot into clipboard' },
    { '<leader>cs', '<cmd>CodeSnapSave<cr>', mode = 'x', desc = 'Save selected code snapshot in ~/Pictures' },
  },
  opts = {
    save_path = '~/Screenshots/CodeSnap',
    bg_padding = 25,
    has_breadcrumbs = true,
    watermark = '@mpriscella',
  },
}
