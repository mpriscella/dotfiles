return {
  -- Matches the Ghostty themes (GitHub Dark/Light Default). Neovim follows
  -- the terminal's reported background (OSC 11 at startup, mode 2031 live),
  -- so the variant tracks the macOS appearance automatically.
  'projekt0n/github-nvim-theme',
  priority = 1000,
  lazy = false,
  config = function()
    require('github-theme').setup({})

    local function apply()
      local want = vim.o.background == 'light'
          and 'github_light_default' or 'github_dark_default'
      if vim.g.colors_name ~= want then
        vim.cmd.colorscheme(want)
      end
    end
    apply()

    -- The colorscheme is applied via vim.schedule rather than directly in the
    -- callback: a :colorscheme run inside an autocmd doesn't fire ColorScheme
    -- (no nesting), which left lualine rebuilding from stale state.
    vim.api.nvim_create_autocmd('OptionSet', {
      group = vim.api.nvim_create_augroup('user-colorscheme-background', { clear = true }),
      pattern = 'background',
      callback = function()
        vim.schedule(apply)
      end,
    })
  end,
}
