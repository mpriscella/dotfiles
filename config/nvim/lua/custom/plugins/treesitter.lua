return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'blade',
        'c',
        'css',
        'diff',
        'html',
        'http',
        'javascript',
        'jsonc',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nix',
        'php',
        'query',
        'regex',
        'scss',
        'terraform',
        'typescript',
        'zig',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = { enable = true },
    },
    init = function()
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.opt.foldlevelstart = 99
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
  },
}
