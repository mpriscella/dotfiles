return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    local npairs = require('nvim-autopairs')
    npairs.setup({})

    local original_cr = npairs.autopairs_cr
    npairs.autopairs_cr = function()
      if vim.bo.filetype == 'php' then
        local line = vim.api.nvim_get_current_line()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local before_cursor = line:sub(1, col)

        if before_cursor:match('%s*/%*%*$') then
          local indent = before_cursor:match('^(%s*)')
          vim.schedule(function()
            vim.fn.append(row, { indent .. ' * ', indent .. ' */' })
            vim.api.nvim_win_set_cursor(0, { row + 1, #indent + 3 })
          end)
          return ''
        end
      end
      return original_cr()
    end
  end
}
