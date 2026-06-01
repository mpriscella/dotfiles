return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Eviline config for lualine
    -- Author: shadmansaleh
    -- Credit: glepnir
    local lualine = require("lualine")

    -- Palettes for each 'background' value, so the statusline follows the
    -- GitHub Dark/Light colorscheme switching.
    local palettes = {
      dark = {
        bg       = '#202328',
        fg       = '#bbc2cf',
        yellow   = '#ECBE7B',
        cyan     = '#008080',
        darkblue = '#081633',
        green    = '#98be65',
        orange   = '#FF8800',
        violet   = '#a9a1e1',
        magenta  = '#c678dd',
        blue     = '#51afef',
        red      = '#ec5f67',
      },
      -- GitHub Light Default-inspired accents.
      light = {
        bg       = '#e1e4e8',
        fg       = '#424a53',
        yellow   = '#9a6700',
        cyan     = '#1b7c83',
        darkblue = '#0a3069',
        green    = '#1a7f37',
        orange   = '#bc4c00',
        violet   = '#8250df',
        magenta  = '#bf3989',
        blue     = '#0969da',
        red      = '#cf222e',
      },
    }

    local function colors()
      return vim.o.background == "light" and palettes.light or palettes.dark
    end

    -- lualine reloads itself on ColorScheme and OptionSet background events.
    -- Passing theme as a function (and component colors as functions) makes
    -- every reload re-resolve against the current palette — no custom
    -- autocmds needed, and nothing fights lualine's own reload.
    local function theme()
      local c = colors()
      return {
        normal = { c = { fg = c.fg, bg = c.bg } },
        inactive = { c = { fg = c.fg, bg = c.bg } },
      }
    end

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
    }

    -- Config
    local config = {
      options = {
        -- Disable sections and component separators
        component_separators = "",
        section_separators = "",
        -- We are going to use lualine_c an lualine_x as left and
        -- right section. Both are highlighted by c theme .  So we
        -- are just setting default looks o statusline
        theme = theme,
      },
      sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {},
      },
      inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
      },
    }

    -- Inserts a component in lualine_c at left section
    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    -- Inserts a component in lualine_x at right section
    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    ins_left({
      function()
        return "▊"
      end,
      color = function()
        return { fg = colors().blue }
      end,
      padding = { left = 0, right = 1 }, -- We don't need space before this
    })

    ins_left({
      -- mode component
      function()
        return ""
      end,
      color = function()
        local c = colors()
        -- auto change color according to neovims mode
        local mode_color = {
          n = c.red,
          i = c.green,
          v = c.blue,
          [""] = c.blue,
          V = c.blue,
          c = c.magenta,
          no = c.red,
          s = c.orange,
          S = c.orange,
          [""] = c.orange,
          ic = c.yellow,
          R = c.violet,
          Rv = c.violet,
          cv = c.red,
          ce = c.red,
          r = c.cyan,
          rm = c.cyan,
          ["r?"] = c.cyan,
          ["!"] = c.red,
          t = c.red,
        }
        return { fg = mode_color[vim.fn.mode()] }
      end,
      padding = { right = 1 },
    })

    ins_left({
      -- filesize component
      "filesize",
      cond = conditions.buffer_not_empty,
    })

    ins_left({
      "filename",
      cond = conditions.buffer_not_empty,
      color = function()
        return { fg = colors().magenta, gui = "bold" }
      end,
      path = 4,
    })

    ins_left({ "location" })

    ins_left({
      "progress",
      color = function()
        return { fg = colors().fg, gui = "bold" }
      end,
    })

    ins_left({
      "diagnostics",
      sources = { "nvim_diagnostic" },
      symbols = { error = " ", warn = " ", info = " " },
      diagnostics_color = {
        error = function()
          return { fg = colors().red }
        end,
        warn = function()
          return { fg = colors().yellow }
        end,
        info = function()
          return { fg = colors().cyan }
        end,
      },
    })

    -- Insert mid section. You can make any number of sections in neovim :)
    -- for lualine it's any number greater then 2
    ins_left({
      function()
        return "%="
      end,
    })

    ins_left({
      "filetype",
      colored = true,        -- Displays filetype icon in color if set to true
      icons_enabled = false, -- { align = 'right' },
    })

    ins_left({
      -- Lsp server name .
      function()
        local msg = "No Active Lsp"
        local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
        local clients = vim.lsp.get_clients()
        if next(clients) == nil then
          return msg
        end
        for _, client in ipairs(clients) do
          ---@type string[]|nil
          local filetypes = client.config.filetypes
          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            return client.name
          end
        end
        return msg
      end,
      icon = " ",
      color = function()
        return { fg = colors().fg, gui = "bold" }
      end,
    })

    ins_right({
      "diff",
      -- Is it me or the symbol for modified us really weird
      symbols = { added = " ", modified = "󰝤 ", removed = " " },
      diff_color = {
        added = function()
          return { fg = colors().green }
        end,
        modified = function()
          return { fg = colors().orange }
        end,
        removed = function()
          return { fg = colors().red }
        end,
      },
      cond = conditions.hide_in_width,
    })

    ins_right({
      function()
        return "▊"
      end,
      color = function()
        return { fg = colors().blue }
      end,
      padding = { left = 1 },
    })

    -- Now don't forget to initialize lualine
    lualine.setup(config)
  end,
}
