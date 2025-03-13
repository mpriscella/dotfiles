return {
  {
    'olimorris/codecompanion.nvim',
    config = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      {
        '<C-a>',
        '<cmd>CodeCompanionActions<cr>',
        desc = 'CodeCompanion [A]ctions',
        mode = { 'n', 'v' },
      },
      {
        '<LocalLeader>a',
        '<cmd>CodeCompanionChat Toggle<cr>',
        desc = 'CodeCompanion Chat Toggle',
        mode = { 'n', 'v' },
      },
      {
        'ga',
        '<cmd>CodeCompanionChat Add<cr>',
        desc = 'CodeCompanion Chat Add',
        mode = 'v',
      },
    },
  },
}
