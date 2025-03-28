return {
  'github/copilot.vim',
  config = function()
    vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
  end,
}
