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
        '<leader>cc',
        '<cmd>CodeCompanionChat Toggle<cr>',
        desc = '[C]ode [C]ompanion',
      },
    },
  },
}
