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
        map("n", "gd", vim.lsp.buf.definition, "Goto definition")
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

    -- If the file `lua_ls.lua` exists in the root of the working directory, set
    -- that as the configpath. This will completely override any other
    -- configurations.
    if vim.uv.fs_stat(vim.fn.getcwd() .. "/lua_ls.lua") then
      language_servers.lua_ls.settings.Lua.cmd = { "lua-language-server", "--configpath=lua_ls.lua" }
    end

    for server, config in pairs(language_servers) do
      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end
  end,
}
