return {
  {
    'sindrets/diffview.nvim',
    config = function()
      require('diffview').setup {
        enhanced_diff_hl = true,
        file_panel = {
          win_config = {
            position = 'right',
          },
        },
      }
    end,
  },
}
