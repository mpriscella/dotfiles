return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
      },
    },
    config = function()
      require('nvim-treesitter').install({
        'bash',
        'blade',
        'c',
        'css',
        'diff',
        'fish',
        'html',
        'http',
        'javascript',
        'json',
        'jsonc',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nix',
        'php',
        'python',
        'query',
        'regex',
        'scss',
        'terraform',
        'typescript',
        'zig',
        'vim',
        'vimdoc',
        'vue',
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')

      local function map_select(lhs, query)
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end)
      end

      map_select('af', '@function.outer')
      map_select('if', '@function.inner')
      map_select('ac', '@class.outer')
      map_select('ic', '@class.inner')
      map_select('aa', '@parameter.outer')
      map_select('ia', '@parameter.inner')

      local function map_move(lhs, dir, query)
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
          move['goto_' .. dir](query, 'textobjects')
        end)
      end

      map_move(']f', 'next_start', '@function.outer')
      map_move(']c', 'next_start', '@class.outer')
      map_move('[f', 'previous_start', '@function.outer')
      map_move('[c', 'previous_start', '@class.outer')
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {},
  },
}
