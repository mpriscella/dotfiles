# Terraform, Helm, and Kubernetes

How the Neovim setup handles infrastructure code: Terraform for cloud and
cluster infrastructure, Helm charts for applications, and plain Kubernetes
manifests for anything in between.

## What's installed

Everything comes from `home-manager/home.nix` — nothing is installed through
Mason or `:TSInstall` by hand.

| Package                | Role                                                         |
| ---------------------- | ------------------------------------------------------------ |
| `terraform`            | `terraform fmt`, and the provider schemas terraform-ls reads |
| `terraform-ls`         | Terraform language server                                    |
| `tflint`               | Provider-aware linting, run in `--langserver` mode           |
| `helm`                 | Chart tooling                                                |
| `helm-ls`              | Helm language server                                         |
| `yaml-language-server` | YAML schemas, and helm-ls's YAML backend                     |
| `kubectl` / `k9s`      | Cluster access                                               |

Neovim-side wiring lives in `config/nvim/lua/custom/plugins/`: `lsp.lua`
(servers and YAML schemas), `helm.lua` (helm-ls.nvim), `autoformat.lua`
(conform), `treesitter.lua` (parsers).

## Filetypes

Which server attaches is decided entirely by filetype, so it's worth knowing
what maps to what. `:set filetype?` in a buffer if something looks wrong.

| Path                                 | Filetype           | Servers               |
| ------------------------------------ | ------------------ | --------------------- |
| `*.tf`                               | `terraform`        | terraformls, tflint   |
| `*.tfvars`                           | `terraform-vars`   | terraformls           |
| `*.hcl`                              | `hcl`              | — (highlighting only) |
| `<chart>/templates/*.{yaml,tpl,txt}` | `helm`             | helm_ls               |
| `values*.yaml`                       | `yaml.helm-values` | helm_ls, yamlls       |
| `Chart.yaml`, everything else        | `yaml`             | yamlls                |

Neovim detects the Terraform and plain-YAML filetypes natively. The two Helm
ones come from [helm-ls.nvim](https://github.com/qvalentin/helm-ls.nvim),
whose `ftdetect/` files lazy.nvim sources at startup even though the plugin
itself only loads on `ft = "helm"`.

The split matters most for chart templates. A `templates/deployment.yaml` is
**not** YAML — it's a Go template that happens to emit YAML — so yamlls must
never attach to it. helm_ls parses the template layer itself and forwards the
rendered result to its own `yaml-language-server` child process, which is why
`settings["helm-ls"].yamlls.path` in `lsp.lua` has to resolve.

## Terraform

`terraform-ls` gives completion, hover, and go-to-definition across modules.
It takes configuration through `init_options` rather than `settings` — it
doesn't implement `workspace/didChangeConfiguration`, so settings passed the
usual way are silently dropped.

Two behaviors are enabled beyond the defaults:

- **`validateOnSave`** — runs `terraform validate` on write, catching bad
  references and type mismatches that parsing alone misses. It needs the
  module to have been `terraform init`-ed; in an uninitialized directory it
  just stays quiet.
- **`prefillRequiredFields`** — completing a `resource`/`data` block stubs out
  its required arguments instead of leaving an empty body.

Completion on _provider_ attributes also depends on `terraform init` having
run, because terraform-ls gets those schemas by shelling out to the
`terraform` binary against the module's lock file.

`tflint` runs as a second language server rather than as a nvim-lint linter.
The nvim-lint definition invokes `tflint --recursive`, which rescans the whole
module tree on every `BufEnter` and `InsertLeave`; language-server mode is
incremental. Projects that ship a `.tflint.hcl` need a one-time
`tflint --init` to fetch its plugins — without one, the built-in ruleset still
applies.

Formatting is `terraform fmt` through conform, not through terraform-ls.
Routing it that way keeps one code path for format-on-save, including the
`:FormatDisable` escape hatch.

`.hcl` files (Terragrunt, Packer, Nomad) get treesitter highlighting but no
server or formatter — the right tool differs per ecosystem, so nothing is
assumed.

## Helm

`helm-ls` resolves `.Values` references against the chart's `values.yaml`:
hover shows the current value, `gd` jumps to where it's defined, and
completion offers the keys that actually exist. It's rooted at `Chart.yaml`,
so it won't engage on YAML that merely happens to sit under a `templates/`
directory.

Because `values.yaml` carries the compound `yaml.helm-values` filetype, both
servers attach to it: yamlls for schema validation and formatting, helm_ls so
it knows which values the sibling templates can reference.

helm-ls.nvim adds the editing affordances on top:

- `%` jumps between the start and end of an `{{ if }}` / `{{ range }}` /
  `{{ with }}` block
- the enclosing block is highlighted
- inline hints show what `indent` / `nindent` actually produce — the single
  easiest thing to get wrong in a chart

One feature is deliberately off: `conceal_templates` replaces
`{{ .Values.foo }}` with the value it resolves to, as virtual text. It's
useful for _reading_ a chart and disorienting for editing, and the plugin
exposes no toggle command, so flip `enabled` in `helm.lua` (along with
`vim.opt.conceallevel = 2`) when you want it.

**Format-on-save is disabled for the `helm` filetype.** helm_ls advertises
formatting but fulfils it through its yamlls child, which reflows the template
as though the Go-template actions were YAML values and destroys the
indentation `nindent` depends on. `values.yaml` still formats normally, with
prettierd.

## Kubernetes YAML

yamlls resolves schemas from three places, in increasing order of precedence.

**1. The schemastore.org catalog**, via
[SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim). This covers
`Chart.yaml`, GitHub Actions workflows, `docker-compose.yml`, `.gitlab-ci.yml`
and several hundred others with no per-file configuration. The catalog is
pinned in `lazy-lock.json` rather than fetched at runtime, which is why
yamlls's own `schemaStore` is disabled.

**2. The bundled Kubernetes schema**, mapped in `lsp.lua` to:

```text
**/k8s/**/*.{yml,yaml}
**/kubernetes/**/*.{yml,yaml}
**/manifests/**/*.{yml,yaml}
*.k8s.{yml,yaml}
```

`"kubernetes"` is a literal key that yamlls special-cases — it selects the
Kubernetes API schema shipped with the server, so there's no URL and no
version to keep current by hand.

The globs are narrow on purpose. Mapping the Kubernetes schema over `*.yaml`
(a common suggestion) makes yamlls reject every unrelated YAML in the repo,
since the schema requires `apiVersion` and `kind`.

Completion is precise — typing under a `Deployment`'s `spec:` offers exactly
`replicas`, `selector`, `strategy`, `template` and friends. Validation
_errors_, though, often collapse to the unhelpful
`Matches multiple schemas when only one must validate.` That's an upstream
limitation of validating against the Kubernetes union schema
([#211](https://github.com/redhat-developer/yaml-language-server/issues/211)),
not a misconfiguration. Use the modeline below when a precise error matters.

**3. A per-file modeline**, which overrides everything above:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/monitoring.coreos.com/prometheus_v1.json
```

This is the escape hatch for CRDs — anything from Argo, Flux, cert-manager,
Prometheus Operator, and so on. The
[datreeio/CRDs-catalog](https://github.com/datreeio/CRDs-catalog) has schemas
for most popular operators. Pointing at a single resource schema (rather than
the union) also gets you specific error messages.

Manifests kept somewhere the globs don't reach can opt in the same way.
