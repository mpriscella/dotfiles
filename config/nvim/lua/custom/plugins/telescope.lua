return {
  'nvim-telescope/telescope.nvim',
  tag = 'v0.2.0',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  keys = {
    {
      '<leader>ff',
      require('telescope.builtin').find_files,
      desc = '[F]ind [f]iles'
    },
    {
      '<leader>fg',
      require('telescope.builtin').live_grep,
      desc = '[F]ind [g]rep'
    },
    {
      '<leader>fh',
      require('telescope.builtin').help_tags,
      desc = '[F]ind [h]elp tags'
    },
  }
}
