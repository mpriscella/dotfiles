return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },

  version = '1.*',

  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    keymap = { preset = 'super-tab' },
    sources = {
      -- blade-nav adds `<x-...>` component / @include / livewire completion.
      -- Its source self-gates to blade+php buffers, so it's harmless in the
      -- global default list. See blade-nav.lua for the navigation half.
      default = { 'lsp', 'path', 'snippets', 'buffer', 'blade-nav' },
      providers = {
        ['blade-nav'] = {
          name = 'blade-nav',
          module = 'blade-nav.integrations.blink',
        },
      },
    },
  },
  opts_extend = { 'sources.default' },
}
