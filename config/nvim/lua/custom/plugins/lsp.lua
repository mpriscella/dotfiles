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
              nixos = {
                expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.k-on.options',
              },
              home_manager = {
                expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options',
              },
            },
          }
        },
      },
      -- https://github.com/phpactor/phpactor
      phpactor = {},
      -- https://github.com/python-lsp/python-lsp-server
      pylsp = {},
      -- https://github.com/tailwindlabs/tailwindcss-intellisense
      tailwindcss = {},
      -- https://github.com/hashicorp/terraform-ls
      terraformls = {},
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
