-- It would be nice if, in a devcontainer, these shells ran in the devcontainer rather than the host.

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

      vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w><C-k>', { desc = 'Move focus up' })

      -- K9s -- Should definitely be its own plugin.
      local Terminal = require('toggleterm.terminal').Terminal
      local mode = require('toggleterm.terminal').mode

      local k9s = Terminal:new {
        cmd = 'k9s',
        hidden = true,
        direction = 'float',
      }

      -- How to make this a local variable? Or do I create a module? M = {} and whatever.
      function k9s_toggle()
        k9s:toggle()
        if k9s:is_open() then
          k9s:set_mode(mode.INSERT)
        end
      end

      vim.keymap.set({ 'n', 't' }, '<S-k>9', '<cmd>lua k9s_toggle()<CR>', { desc = 'Toggle K9s' })

      -- htop
      local htop = Terminal:new {
        cmd = 'htop',
        hidden = true,
        direction = 'float',
      }

      function htop_toggle()
        htop:toggle()
        if htop:is_open() then
          htop:set_mode(mode.INSERT)
        end
      end

      vim.keymap.set({ 'n', 't' }, '<leader>ht', '<cmd>lua htop_toggle()<CR>', { desc = 'Toggle Htop' })
    end,
  },
}
