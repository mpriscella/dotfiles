return {
  {
    'EthanJWright/vs-tasks.nvim',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('vstask').setup {}
    end,
    keys = {
      {
        '<leader>ta',
        function()
          require('telescope').extensions.vstask.tasks()
        end,
        mode = 'n',
        desc = 'VSCode [TA]sks',
      },
    },
  },
}
