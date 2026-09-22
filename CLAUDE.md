# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Overview

Cross-platform dotfiles managed with Nix flakes, nix-darwin (macOS), and Home
Manager (Linux). Provides reproducible system and user-level configuration with
host-specific overrides.

## Common Commands

```bash
# Enter development shell (required for darwin-rebuild, home-manager)
nix develop

# Apply configuration (nh shows a package diff; preferred)
nh darwin switch -H <hostname>                 # macOS
nh home switch -c <config>                     # Linux

# Apply configuration (without nh)
darwin-rebuild switch --flake .#<hostname>     # macOS
home-manager switch --flake .#<config>         # Linux

# Validate and test
nix flake check

# Format code (avoid recursive due to nvim cache dirs)
nix fmt flake.nix home-manager nix-darwin

# Update dependencies
nix flake update

# Neovim with isolated config
nvim-dev [files]
```

## Available Configurations

**macOS (nix-darwin):** `macbook-pro-m5`, `macbook-pro-m3`

**Linux (home-manager):** `linux`, `linux-arm`

**Codespaces / dev containers (home-manager):** `codespaces`, `codespaces-arm`

## Architecture

- **flake.nix** - Entry point defining inputs, outputs, and all configurations.
  Contains `mkDarwinConfiguration` and `mkHomeConfiguration` helper functions.
- **home-manager/home.nix** - Main Home Manager config importing all program
  modules
- **home-manager/codespaces.nix** - Minimal alternative to `home.nix` (not
  combined with it): Neovim, fish, starship, git, jj. No sops, GPG, or cloud
  tooling. Selected via the `homeModule` argument to `mkHomeConfiguration`.
- **home-manager/modules/neovim.nix** - Neovim, its language servers, and
  `~/.config/nvim`, shared by both profiles. The nvim and ghostty configs are
  linked in from the Nix store, so edits under `config/` need a rebuild to
  take effect; use `nvim-dev` (from `nix develop`) to iterate against the
  working tree instead.
- **home-manager/programs/*.nix** - Modular program configurations (git, fish,
  claude-code, etc.)
- **nix-darwin/base.nix** - macOS system-level config (keyboard, homebrew, GUI
  apps). Includes Home Manager as a module.
- **config/nvim/** - Neovim IDE configuration (Lua-based with LSP, Telescope,
  Treesitter)
- **agents/** - Claude Code subagent definitions, deployed via
  `programs.claude-code.agentsDir` in `home-manager/programs/claude-code.nix`
- **skills/** - Claude Code skill definitions, deployed via
  `programs.claude-code.skills` in `home-manager/programs/claude-code.nix`
- **secrets/** - Encrypted secrets using sops-nix with age encryption

Packages that aren't in nixpkgs live in
[mpriscella/nix-packages](https://github.com/mpriscella/nix-packages), not in
this repo. Its `overlays.default` is applied in both config paths in
`flake.nix`, so they resolve as ordinary attributes (e.g. `pkgs.laravel-lsp`).
Add a new custom package there rather than reintroducing a local `pkgs/`
directory.

## Key Conventions

- All macOS configuration goes through nix-darwin, not standalone Home Manager
- Home Manager is included as a nix-darwin module for unified macOS config
- Per-host GPG signing keys are passed via `gpgSigningKey` parameter
- Secrets are edited with `sops secrets/secrets.yaml` (never commit unencrypted)
- Neovim config is Lua-based, not VimScript
- Follow Conventional Commits for PR titles (feat:, fix:, chore:, docs:)

## Adding New Program Configuration

1. Create `home-manager/programs/<program>.nix`
2. Import it in `home-manager/home.nix`
3. Test with `nix flake check`
4. Apply with `darwin-rebuild switch` or `home-manager switch`
