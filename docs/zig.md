# Zig

## Toolchain

The dotfiles install `pkgs.zig` and `pkgs.zls` from the weekly nixpkgs
snapshot (see `home-manager/home.nix`). nixpkgs keeps the two in lockstep
(currently 0.16.0 / 0.16.0), so for general hacking on Zig **the
dotfiles-managed toolchain is all you need** — no per-project setup required.

Use [zig-overlay](https://github.com/mitchellh/zig-overlay) instead when a
project pins its own Zig version in a flake: nixpkgs only carries the latest
stable release, while zig-overlay mirrors every official release binary
(tagged versions and nightlies) without building from source.

The quickest way to start such a project (the `templates` alias comes from
the flake registry entry in `home-manager/home.nix` and points at
[mpriscella/nix-templates](https://github.com/mpriscella/nix-templates)):

```sh
nix flake init -t templates#zig
direnv allow
```

Or add it to an existing flake by hand:

```nix
inputs.zig-overlay = {
  url = "github:mitchellh/zig-overlay";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Available packages (per system):

| Attribute                  | What you get                        |
| -------------------------- | ----------------------------------- |
| `default`                  | Latest tagged release               |
| `"0.16.0"` (any tag)       | That exact release                  |
| `master`                   | Latest nightly                      |
| `master-<yyyy-mm-dd>`      | Nightly from a specific date        |

Because direnv puts the project flake's toolchain first on `PATH`, Neovim
started inside the project automatically picks up the pinned `zig` (and
`zls`, if the project provides one) — no editor config changes needed.

## Matching zls to the compiler

zls only works reliably against the Zig version it was built for
(major.minor must match). Rules of thumb:

- **Tagged release** — pair zig-overlay's tagged package with `pkgs.zls`
  from nixpkgs; both track the latest stable, so they line up. If the
  project pins an *older* release, pin nixpkgs to a snapshot whose zls
  matches.
- **Nightly (`master`)** — nixpkgs' zls will be too old. Take zls from the
  [zigtools/zls](https://github.com/zigtools/zls) flake
  (`inputs.zls.url = "github:zigtools/zls";` →
  `inputs.zls.packages.${system}.zls`), which tracks Zig master.

## Build-on-save diagnostics

zls is configured (in `config/nvim/lua/custom/plugins/lsp.lua`) with
`enable_build_on_save`, so every save runs `zig build` and surfaces full
compile errors as diagnostics — without it zls only reports AST-level
errors, and type errors stay invisible until a manual build.

Builds use the default install step unless `build.zig` defines a `check`
step, which zls prefers. Adding one keeps save-time feedback fast because it
compiles without emitting binaries:

```zig
const exe_check = b.addExecutable(.{
    .name = "my-app",
    .root_module = mod,
});
const check = b.step("check", "Semantic analysis only, no binary");
check.dependOn(&exe_check.step);
```

## Debugging and tests in Neovim

- `nvim-dap` has an `lldb-dap` adapter (from `pkgs.lldb`) with a Zig launch
  configuration that prompts for a binary, prefilled to `zig-out/bin/`.
  Build in Debug mode (the `zig build` default) for usable debug info.
- `neotest-zig` wires the usual `<leader>tt` / `<leader>tf` / `<leader>ts`
  keymaps to `zig test`.
