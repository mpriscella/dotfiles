return {
  dir = '~/workspace/mpriscella/panelterm.nvim',
  name = 'panelterm.nvim',
  config = function()
    require('panelterm').setup {}

    vim.keymap.set('t', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
    vim.keymap.set('t', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
    vim.keymap.set('t', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
    vim.keymap.set('t', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

    vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], { desc = 'Move focus to the left window' })
    vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], { desc = 'Move focus to the right window' })
    vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], { desc = 'Move focus to the lower window' })
    vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], { desc = 'Move focus to the upper window' })
  end,
  keys = {
    {
      '<leader>t',
      mode = { 'n', 't' },
      function()
        require('panelterm.panel').toggle_panel()
      end,
      desc = '[T]oggle Panel',
    },
  },
}
