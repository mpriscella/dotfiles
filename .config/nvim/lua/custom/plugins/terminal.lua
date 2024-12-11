local size = 18

return {
  {
    'akinsho/toggleterm.nvim',
    version = 'v2.13.0',
    opts = {
      autochdir = true,
      open_mapping = [[<leader>st]],
      size = size,
    },
    init = function()
      vim.keymap.set('t', '<leader>x', function()
        -- This functionality may be good to extract into a separate plugin.
        local current_size = vim.fn.winheight(0)
        if current_size > size then
          vim.cmd(string.format('resize %s<CR>', size))
        else
          vim.cmd 'resize 100<CR>'
        end
      end, { desc = 'Toggle Maximized Terminal' })
    end,
  },
}
