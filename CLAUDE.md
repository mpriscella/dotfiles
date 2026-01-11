# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Cross-platform dotfiles managed with Nix flakes, nix-darwin (macOS), and Home Manager (Linux). Provides reproducible system and user-level configuration with host-specific overrides.

## Common Commands

```bash
# Enter development shell (required for darwin-rebuild, home-manager)
nix develop

# Apply configuration
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

**macOS (nix-darwin):** `macbook-pro-m5`, `macbook-pro-m3`, `macbook-air-m4`

**Linux (home-manager):** `linux`, `linux-arm`

## Architecture

- **flake.nix** - Entry point defining inputs, outputs, and all configurations. Contains `mkDarwinConfiguration` and `mkHomeConfiguration` helper functions.
- **home-manager/home.nix** - Main Home Manager config importing all program modules
- **home-manager/programs/*.nix** - Modular program configurations (git, fish, claude-code, etc.)
- **nix-darwin/base.nix** - macOS system-level config (keyboard, homebrew, GUI apps). Includes Home Manager as a module.
- **config/nvim/** - Neovim IDE configuration (Lua-based with LSP, Telescope, Treesitter)
- **secrets/** - Encrypted secrets using sops-nix with age encryption

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
