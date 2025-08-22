return {
  'nvim-tree/nvim-web-devicons',
  config = function()
    require('nvim-web-devicons').setup {
      override = {
        php = {
          icon = '',
          color = '#a074c4',
          cterm_color = '140',
          name = 'Php',
        },
      },
    }
  end,
}
