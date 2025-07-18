# Copilot Instructions for `dotfiles`

## Overview
This repository manages cross-platform dotfiles using Nix flakes, Home Manager, and nix-darwin (for macOS). It supports both user-level and system-level configuration, with host-specific overrides. The structure is optimized for reproducibility and multi-host management.

## Architecture
- **flake.nix**: Entry point. Defines all flake inputs (nixpkgs, home-manager, nix-darwin, etc.) and outputs (darwinConfigurations for macOS, devShells, formatters, packages).
- **home/modules/**: Shared configuration modules (`darwin.nix`, `home-base.nix`) for reuse across hosts.
- **home/programs/**: Individual program configurations (git.nix, fish.nix, etc.) imported by `home-base.nix`.
- **nix-darwin**: Used for system-level configuration on macOS. Home Manager is included as a module within nix-darwin for unified management.

## Key Workflows
- **System configuration (macOS):**
  - Use `darwin-rebuild switch --flake .#<hostname>` to apply both system and user configuration.
  - Example: `darwin-rebuild switch --flake .#macbook-pro-m3`
  - For new installs: `nix run nix-darwin -- switch --flake .#<hostname>`
- **Development shell:**
  - Enter with `nix develop` for a shell with all dev tools and commands.
- **Update dependencies:**
  - Run `nix flake update` to update all flake inputs.
- **Format code:**
  - Use `nix fmt flake.nix home/` to format Nix files (avoid recursive formatting due to cache dirs).
- **Neovim development:**
  - Use `./nvim-dev.sh` for isolated Neovim environment with local config.

## Project Conventions
- **All macOS configuration is managed via nix-darwin.** Do not use standalone `homeConfigurations` for macOS hosts; use `darwinConfigurations` instead.
- **User-level configuration is managed via Home Manager as a nix-darwin module.**
- **Host-specific logic** is currently defined inline in `flake.nix` but should be moved to `home/hosts/<hostname>.nix` following the project's intended structure.
- **Packages** for each system are defined in `defaultPackages` function in `flake.nix`.
- **Program configurations** are modularized in `home/programs/` and imported via `home-base.nix`.

## Current Structure vs. Intended Structure
- **Current**: Host configurations are defined inline in `flake.nix` 
- **Intended**: Host configurations should be in `home/hosts/<hostname>.nix` files
- **When adding new hosts**: Create `home/hosts/<hostname>.nix` and import it in `flake.nix` modules list

## Shell Configuration
- **Fish shell**: Enable via `programs.fish.enable = true` in nix-darwin config
- **Shell setup**: Set user shell with `users.users.<username>.shell = pkgs.fish`
- **Note**: nix-darwin automatically adds enabled shells to `/etc/shells`

## GPG Configuration
- **Per-host GPG keys**: Use `gpgConfig.gpgSigningKey` option in Home Manager config
- **Git signing**: Automatically configured when `gpgSigningKey` is set
- **Example**: `gpgConfig = { gpgSigningKey = "799887D03FE96FD0"; };`

## Integration Points
- **nix-darwin**: System-level macOS configuration, including Home Manager as a module.
- **Home Manager**: User-level configuration, dotfiles, and packages.
- **Nixpkgs**: Source of all packages and system tools.

## Troubleshooting
- If a configuration fails, check the relevant host configuration and shared modules for errors.
- Use `nix flake check` to validate the flake.
- For macOS, always use `darwin-rebuild` for system changes, not `home-manager switch`.
- Format specific paths only: `nix fmt flake.nix home/` (not recursive due to nvim-cache directories).

## References
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
