return {
  'f-person/git-blame.nvim',
  -- Off by default; load on demand when toggled on.
  cmd = { "GitBlameToggle", "GitBlameEnable", "GitBlameDisable" },
  keys = {
    { "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle [g]it [b]lame" },
  },
  opts = {
    enabled = false,
  },
}
