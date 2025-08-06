vim.bo.commentstring = '# %s'

local function add_comment_header()
  local line_length = 80
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local bookend = '################################################################################'

  -- for i = 1, line_length, 1 do
  --   bookend = bookend .. '#'
  -- end

  vim.api.nvim_buf_set_lines(0, current_line - 1, current_line, true, {
    bookend,
    '# ' .. line,
  })
  vim.api.nvim_buf_set_lines(0, current_line + 1, current_line + 1, true, { bookend })

  if line == '' then
    vim.api.nvim_win_set_cursor(0, { current_line + 1, 2 })
    vim.cmd 'startinsert'
  end
end

vim.keymap.set('n', 'gh', add_comment_header, { desc = 'Add Comment Header' })
