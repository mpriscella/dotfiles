return {
  -- TODO: All of these types should be included in the lua language server.
  --
  -- @see https://github.com/folke/snacks.nvim
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    ---@type snacks.indent.Config|{}
    indent = { enabled = true },
    ---@type snacks.input.Config|{}
    input = { enabled = true },
    ---@type snacks.lazygit.Config|{}
    lazygit = { enabled = true },
    ---@type snacks.notifier.Config|{}
    notifier = {
      enabled = true,
    },
    ---@type snacks.quickfile.Config|{}
    quickfile = { enabled = true },
    ---@type snacks.statuscolumn.Config|{}
    statuscolumn = { enabled = true },
    ---@type snacks.words.Config|{}
    words = { enabled = true },
  },
}
