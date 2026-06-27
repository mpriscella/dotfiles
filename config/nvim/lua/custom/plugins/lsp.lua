return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "j-hui/fidget.nvim",
      opts = {
        notification = {
          window = {
            avoid = { 'NvimTree' }
          }
        }
      }
    },
  },
  config = function()
    vim.filetype.add({
      extension = {
        tf = "terraform"
      }
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
      callback = function(event)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        -- K (hover), grn (rename), gra (code action), grr (references), gri
        -- (implementation), gO (document symbols), ]d/[d (diagnostics) are
        -- Neovim 0.11+ defaults — only adding what's missing or worth aliasing.
        -- gd jumps in place (picker when there are multiple results); gdl opens
        -- the definition in a vertical split (right, per splitright), gdj in a
        -- horizontal split (below, per splitbelow).
        map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Goto definition")
        map("n", "gdl", function() Snacks.picker.lsp_definitions({ confirm = "edit_vsplit" }) end,
          "Goto definition in vertical split")
        map("n", "gdj", function() Snacks.picker.lsp_definitions({ confirm = "edit_split" }) end,
          "Goto definition in horizontal split")
        map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
        map("n", "gy", vim.lsp.buf.type_definition, "Goto type definition")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
      end,
    })

    local language_servers = {
      -- https://github.com/bash-lsp/bash-language-server
      bashls = {},
      -- https://github.com/mrjosh/helm-ls
      helm_ls = {},
      -- https://github.com/luals/lua-language-server
      lua_ls = {
        -- https://luals.github.io/wiki/settings/
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              globals = { "vim" },
            },
            format = {
              enable = true,
              indent_style = "space",
              indent_size = 2,
            },
          },
        },
      },
      -- https://github.com/nix-community/nixd
      nixd = {
        settings = {
          nixd = {
            nixpkgs = {
              expr = "import <nixpkgs> { }",
            },
            formatting = {
              command = { "alejandra" },
            },
            options = {
              darwin = {
                expr = '(builtins.getFlake ("git+file://" + toString ./.)).darwinConfigurations."macbook-pro-m5".options',
              },
              home_manager = {
                expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."linux".options',
              },
            },
          }
        },
      },
      -- https://github.com/phpactor/phpactor
      -- mago owns diagnostics (see lint.lua); phpactor's are disabled via
      -- ~/.config/phpactor/phpactor.json (managed in home-manager/home.nix).
      -- init_options don't work for this: phpactor outsources diagnostics to
      -- a subprocess that only reads config files.
      phpactor = {},
      -- https://github.com/python-lsp/python-lsp-server
      pylsp = {},
      -- https://github.com/swiftlang/sourcekit-lsp
      sourcekit = {},
      -- https://github.com/tailwindlabs/tailwindcss-intellisense
      tailwindcss = {},
      -- https://github.com/hashicorp/terraform-ls
      terraformls = {},
      -- https://github.com/typescript-language-server/typescript-language-server
      ts_ls = {},
      -- https://github.com/zigtools/zls
      zls = {},
    }

    -- Per-project overrides come from a `.luarc.json`/`.luarc.jsonc` in the
    -- workspace root, which lua-language-server auto-discovers and merges over
    -- the settings above. No editor-side detection needed.

    for server, config in pairs(language_servers) do
      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end
  end,
}
