return {
  'github/copilot.vim',
  config = function()
    vim.g.copilot_filetypes = {
      ['codecompanion'] = false,
      ['helm'] = false,
      ['markdown'] = false,
      ['terraform'] = false,
    }
    vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
  end,
}
