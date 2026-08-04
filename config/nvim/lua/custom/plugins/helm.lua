-- Companion plugin for helm-ls (the language server is configured in lsp.lua
-- and installed from nixpkgs in home-manager/home.nix). Upstream helm-ls
-- recommends this over towolf/vim-helm for Neovim.
--
-- Its main job is filetype detection, which nothing else provides:
--   */templates/*.{yaml,tpl,txt}  -> helm              (go-template + yaml)
--   values*.yaml                  -> yaml.helm-values  (plain yaml)
--   helmfile*.yaml[.gotmpl]       -> helm
--
-- The compound `yaml.helm-values` filetype is what lets yamlls and helm_ls
-- both attach to a chart's values.yaml: yamlls for schema validation, helm_ls
-- so it knows which values the templates in the same chart can reference.
-- Neovim resolves compound filetypes to their leading component for
-- treesitter, so values files still highlight with the `yaml` parser.
--
-- The ftdetect/ directory is sourced at startup even though the plugin itself
-- is lazy-loaded on `ft = "helm"` — that's lazy.nvim-specific, and the reason
-- upstream warns vim-helm breaks under other plugin managers.
return {
  "qvalentin/helm-ls.nvim",
  ft = "helm",
  opts = {
    -- Replaces `{{ .Values.foo }}` with the value it resolves to from
    -- values.yaml, as virtual text. Upstream defaults this on, but it hides
    -- the template source you're editing and there's no toggle command —
    -- flip it here (plus `vim.opt.conceallevel = 2`) to read a chart rendered.
    conceal_templates = {
      enabled = false,
    },
    -- Highlights what `indent`/`nindent` actually produce, which is the
    -- single easiest thing to get wrong in a chart.
    indent_hints = {
      enabled = true,
      only_for_current_line = true,
    },
    -- Highlight the enclosing {{ if }}/{{ range }}/{{ with }} block.
    action_highlight = {
      enabled = true,
    },
  },
}
