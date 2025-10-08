return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "j-hui/fidget.nvim", opts = {} },
  },
  config = function()
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
            runtime = {
              version = "LuaJIT",
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
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
      -- https://github.com/hashicorp/terraform-ls
      terraformls = {},
      -- https://github.com/zigtools/zls
      zls = {},
    }

    for server, config in pairs(language_servers) do
      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end
  end,
}
