return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- Opt a project out of rendering by adding a `.norender-markdown` file
    -- anywhere at or above the file's directory (typically the repo root).
    ignore = function(buf)
      local name = vim.api.nvim_buf_get_name(buf)
      if name == '' then
        return false
      end
      return vim.fs.root(name, '.norender-markdown') ~= nil
    end,
  },
}
