return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      style = 'night',
      on_colors = function(colors)
        colors.border = 'orange'
      end,
    },
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
}
