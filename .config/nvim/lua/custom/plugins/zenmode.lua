-- Enable ZenMode.
--
-- Commands:
--   ZenMode - Toggles Zen Mode.
return {
  {
    'folke/zen-mode.nvim',
    opts = {
      plugins = {
        tmux = { enabled = true },
      },
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
}
