return {
  {
    'akinsho/toggleterm.nvim',
    version = 'v2.12.0',
    config = function()
      require('toggleterm').setup {
        direction = 'float',
        open_mapping = [[<C-\>]],
      }
    end,
  },
}
