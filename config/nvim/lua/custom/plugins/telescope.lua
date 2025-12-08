return {
  'nvim-telescope/telescope.nvim',
  tag = 'v0.2.0',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    local telescope = require("telescope")
    local telescopeConfig = require("telescope.config")

    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    table.insert(vimgrep_arguments, "--hidden")
    table.insert(vimgrep_arguments, "--glob")
    table.insert(vimgrep_arguments, "!**/.git/*")

    telescope.setup({
      defaults = {
        vimgrep_arguments = vimgrep_arguments
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" }
        }
      }
    })
  end,
  keys = {
    {
      '<leader>fds',
      require('telescope.builtin').lsp_document_symbols,
      desc = '[F]ind [d]ocument [s]ymbols'
    },
    {
      '<leader>ff',
      require('telescope.builtin').find_files,
      desc = '[F]ind [f]iles'
    },
    {
      '<leader>fh',
      require('telescope.builtin').help_tags,
      desc = '[F]ind [h]elp tags'
    },
    {
      '<leader>fr',
      require('telescope.builtin').lsp_references,
      desc = '[F]ind [r]eferences'
    },
    {
      '<leader>gs',
      require('telescope.builtin').live_grep,
      desc = '[G]rep [s]tring'
    },
    {
      '<leader>km',
      require('telescope.builtin').keymaps,
      desc = '[K]ey [m]aps'
    },
    {
      '<leader>sd',
      require('telescope.builtin').diagnostics,
      desc = '[S]earch [d]iagnostics'
    },
    {
      '<leader>st',
      require('telescope.builtin').treesitter,
      desc = '[S]earch [t]reesitter'
    },
  }
}
