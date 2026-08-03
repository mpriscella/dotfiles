# Slidev

[Slidev](https://sli.dev) decks are markdown files with embedded Vue, plus
custom Vue components under `components/`. The relevant editor wiring:

- **Vue**: `vue_ls` + `ts_ls` with `@vue/typescript-plugin` (see
  `config/nvim/lua/custom/plugins/lsp.lua`) give completion and diagnostics
  in `.vue` component files. `vue-language-server` is installed via
  `home-manager/home.nix`.
- **Markdown**: `markdownlint` lints (via nvim-lint) and `prettierd`
  formats on save (via conform). Both are tuned for prose, not slides, so
  deck repos want the per-project opt-outs below.

## markdownlint: `.markdownlint.yaml`

Slidev decks violate prose-oriented rules by design: every slide has its own
H1, components are inline HTML, and long lines are normal in frontmatter and
component props. `markdownlint` discovers `.markdownlint.yaml` by walking up
from the linted file, so dropping one in the deck repo root quiets it with
no editor changes:

```yaml
# Slidev decks are HTML-in-markdown by design.
MD013: false # line-length: long lines are fine in slides
MD025: false # single-h1: each slide has its own top-level heading
MD033: false # no-inline-html: Vue components are the point
MD035: false # hr-style: `---` slide separators vs other hr styles
```

Extend as rules get noisy; `:lua vim.diagnostic.open_float()` shows the rule
code (e.g. `MD025`) for whatever fires.

## prettier: `.prettierignore`

conform runs `prettierd` on every markdown save, and prettier reflows
markdown in ways that can fight Slidev's structure (per-slide frontmatter
blocks between `---` separators). prettierd resolves ignore files the same
way prettier does, so ignore the deck entrypoints in the repo root:

```
# Slidev decks: prettier reflows slide separators/frontmatter.
slides.md
pages/*.md
```

Component files (`components/*.vue`) format fine — don't ignore those.

## Escape hatch

For a one-off buffer where formatting misbehaves, `:FormatDisable!` turns
format-on-save off for that buffer only (`:FormatDisable` for everything,
`:FormatEnable` to undo). Defined in
`config/nvim/lua/custom/plugins/autoformat.lua`.
