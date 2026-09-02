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
    -- Catalog of JSON/YAML schemas from schemastore.org, consumed by yamlls
    -- below. Ships the mappings for GitHub Actions, Chart.yaml, .gitlab-ci,
    -- docker-compose, etc. so they don't have to be hand-maintained here.
    "b0o/SchemaStore.nvim",
  },
  config = function()
    vim.filetype.add({
      -- `.blade.php` is a compound extension, so it must be matched as a
      -- pattern (Lua pattern), not via `extension`/`filename`. This is the
      -- linchpin for Blade support: without it these files match `*.php` and
      -- open as `php`, never engaging the blade treesitter parser,
      -- blade-formatter, or laravel.nvim.
      pattern = {
        [".*%.blade%.php"] = "blade"
      }
    })

    -- Disable LSP document color (Neovim 0.12, on by default). Its request()
    -- asserts the client still exists, but the buffer's on_lines callback can
    -- fire while a server is shutting down (e.g. phpactor restart + delete a
    -- line), hitting a stale client id and crashing with an assertion failure.
    -- We don't use color swatches anyway. Guarded so older Neovim still loads.
    if vim.lsp.document_color then
      vim.lsp.document_color.enable(false)
    end

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

        -- Inlay hints (e.g. gopls parameter/type hints). Enable when the
        -- attached server supports them; <leader>th toggles them per-buffer.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          map("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
              { bufnr = event.buf }
            )
          end, "Toggle inlay hints")
        end
      end,
    })

    -- @vue/typescript-plugin ships inside the vue-language-server package;
    -- nixpkgs installs the language-tools monorepo next to the binary
    -- (bin/../lib/language-tools/packages/typescript-plugin), so resolve it
    -- relative to the wrapper (through the profile symlink) rather than
    -- hardcoding a store path. Nil when the layout doesn't match — ts_ls
    -- then runs without Vue support instead of failing to start.
    local vue_ts_plugin
    do
      local bin = vim.fn.exepath("vue-language-server")
      local real = bin ~= "" and vim.uv.fs_realpath(bin) or nil
      if real then
        local path = vim.fs.normalize(
          vim.fs.dirname(real) .. "/../lib/language-tools/packages/typescript-plugin"
        )
        vue_ts_plugin = vim.uv.fs_stat(path) and path or nil
      end
    end

    -- YAML schema map for yamlls: `{ [schema url] = file glob(s) }`.
    -- SchemaStore.nvim supplies the schemastore.org catalog (GitHub Actions,
    -- Chart.yaml, docker-compose, .gitlab-ci, ...); Kubernetes is layered on
    -- top because yamlls special-cases it — the literal key "kubernetes"
    -- selects the k8s API schema bundled with the server, so there's no URL
    -- and no version to keep current by hand.
    --
    -- The globs are deliberately narrow. Mapping the k8s schema over `*.yaml`
    -- (a common suggestion) makes yamlls reject every unrelated YAML in the
    -- repo as an invalid manifest, since the schema requires apiVersion/kind.
    -- Anything outside these paths can opt in per-file with a modeline.
    local schemas = require("schemastore").yaml.schemas()
    schemas["kubernetes"] = {
      "**/k8s/**/*.{yml,yaml}",
      "**/kubernetes/**/*.{yml,yaml}",
      "**/manifests/**/*.{yml,yaml}",
      "*.k8s.{yml,yaml}",
    }

    local language_servers = {
      -- https://github.com/bash-lsp/bash-language-server
      bashls = {},
      -- https://github.com/olrtg/emmet-language-server
      -- HTML/Tailwind abbreviation expansion in blade templates (and the
      -- usual web filetypes). Overriding `filetypes` replaces the server
      -- default, so `blade` must be listed explicitly alongside the rest.
      emmet_language_server = {
        filetypes = { "blade", "html", "css", "scss", "javascriptreact", "typescriptreact", "vue" },
      },
      -- https://github.com/golang/tools/tree/master/gopls
      -- Shells out to the `go` toolchain (packaged in home.nix).
      -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            usePlaceholders = true,
            completeUnimported = true,
            analyses = {
              unusedparams = true,
              unusedwrite = true,
              nilness = true,
              shadow = true,
              useany = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      },
      -- https://github.com/mrjosh/helm-ls
      -- Attaches to the `helm` and `yaml.helm-values` filetypes, neither of
      -- which Neovim detects on its own — helm-ls.nvim supplies both (see
      -- lua/custom/plugins/helm.lua). Rooted at Chart.yaml, so it stays out
      -- of yaml that merely lives under a `templates/` directory.
      --
      -- helm-ls parses the go-template layer itself and hands the rendered
      -- YAML to its own yaml-language-server child process for schema
      -- validation, so `path` must resolve. Never enable yamlls on the `helm`
      -- filetype directly: it would parse `{{ ... }}` as YAML and drown the
      -- buffer in syntax errors.
      helm_ls = {
        settings = {
          ["helm-ls"] = {
            yamlls = {
              enabled = true,
              path = "yaml-language-server",
            },
          },
        },
      },
      -- https://github.com/laravel/lsp
      laravel_lsp = {
        cmd = { "laravel-lsp" },
        filetypes = { "php", "blade" },
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, "artisan")

          if root then
            on_dir(root)
          end
        end,
      },
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
      -- Covers `terraform` and `terraform-vars` (Neovim 0.12 detects both from
      -- .tf/.tfvars natively). terraform-ls takes settings through
      -- `init_options`, not `settings` — it doesn't implement
      -- workspace/didChangeConfiguration.
      terraformls = {
        init_options = {
          experimentalFeatures = {
            -- Run `terraform validate` on write, surfacing the errors a parse
            -- alone can't see (bad references, type mismatches). Needs the
            -- module to have been `terraform init`-ed; stays quiet otherwise.
            validateOnSave = true,
            -- Completing a resource/data block stubs out its required
            -- arguments instead of an empty body.
            prefillRequiredFields = true,
          },
        },
      },
      -- https://github.com/terraform-linters/tflint
      -- tflint in language-server mode, alongside terraformls: terraform-ls
      -- checks syntax and schema, tflint checks provider-specific rules
      -- (invalid instance types, deprecated syntax, naming conventions).
      -- Runs plugin rules only where the project ships a `.tflint.hcl` and
      -- has run `tflint --init`; otherwise it applies the built-in ruleset.
      tflint = {},
      -- https://github.com/typescript-language-server/typescript-language-server
      -- Loads @vue/typescript-plugin so tsserver can type-check the script
      -- blocks of .vue files (vue_ls hybrid mode only owns template/CSS and
      -- forwards its tsserver requests here — see vue_ls below). `vue` must
      -- be in filetypes so ts_ls attaches to SFCs; overriding filetypes
      -- replaces the server default, so the standard ones are repeated.
      ts_ls = {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
        init_options = {
          plugins = vue_ts_plugin and {
            {
              name = "@vue/typescript-plugin",
              location = vue_ts_plugin,
              languages = { "vue" },
            },
          } or nil,
        },
      },
      -- https://github.com/vuejs/language-tools
      -- Hybrid mode (3.x): vue_ls only serves the template/style parts of
      -- SFCs (and the Vue embedded in Slidev decks' components); TypeScript
      -- inside .vue files is served by ts_ls via @vue/typescript-plugin
      -- (see ts_ls above). nvim-lspconfig's bundled vue_ls config wires up
      -- the tsserver/request forwarding between the two.
      vue_ls = {},
      -- https://github.com/redhat-developer/yaml-language-server
      -- Schema-driven completion, hover, and validation for plain YAML.
      -- Attaches to `yaml`, `yaml.docker-compose`, `yaml.gitlab`, and
      -- `yaml.helm-values` — chart *templates* (filetype `helm`) are served by
      -- helm_ls instead, which runs its own yamlls child.
      yamlls = {
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            -- The built-in schema store is replaced by SchemaStore.nvim so the
            -- catalog is versioned with the config rather than fetched at
            -- runtime. `url = ""` is required alongside `enable = false`;
            -- yamlls still reads the field and errors on a nil.
            schemaStore = { enable = false, url = "" },
            -- A `# yaml-language-server: $schema=<url>` modeline at the top of
            -- a file overrides whatever this map resolves to. That's the
            -- escape hatch for CRDs — point it at the matching entry in
            -- https://github.com/datreeio/CRDs-catalog.
            schemas = schemas,
            format = { enable = true },
            validate = true,
            -- Don't demand alphabetically sorted keys. Kubernetes convention
            -- is apiVersion/kind/metadata/spec, which is the opposite.
            keyOrdering = false,
          },
        },
      },
      -- https://github.com/zigtools/zls
      -- Build-on-save (off by default) runs `zig build` on save and surfaces
      -- full compile errors as diagnostics — zls alone only reports
      -- AST-level errors, so type errors stay invisible until a manual
      -- build. Prefers a `check` step when build.zig defines one (see
      -- docs/zig.md).
      zls = {
        settings = {
          zls = {
            enable_build_on_save = true,
          },
        },
      },
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
