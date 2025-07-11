# Copilot Instructions for `dotfiles`

## Overview
This repository manages cross-platform dotfiles using Nix flakes, Home Manager, and nix-darwin (for macOS). It supports both user-level and system-level configuration, with host-specific overrides. The structure is optimized for reproducibility and multi-host management.

## Architecture
- **flake.nix**: Entry point. Defines all flake inputs (nixpkgs, home-manager, nix-darwin, etc.) and outputs (darwinConfigurations for macOS, devShells, formatters, packages).
- **home/hosts/**: Per-host configuration files (e.g., `macbook-pro-m3.nix`). These are imported as modules in the flake outputs.
- **home/modules/**: Shared configuration modules (e.g., `darwin-base.nix`) for reuse across hosts.
- **nix-darwin**: Used for system-level configuration on macOS. Home Manager is included as a module within nix-darwin for unified management.

## Key Workflows
- **System configuration (macOS):**
  - Use `darwin-rebuild switch --flake .#<hostname>` to apply both system and user configuration.
  - Example: `darwin-rebuild switch --flake .#macbook-pro-m3`
- **Development shell:**
  - Enter with `nix develop` for a shell with all dev tools and commands.
- **Update dependencies:**
  - Run `nix flake update` to update all flake inputs.
- **Format code:**
  - Use `nixpkgs-fmt .` or `nix fmt` to format Nix files.

## Project Conventions
- **All macOS configuration is managed via nix-darwin.** Do not use standalone `homeConfigurations` for macOS hosts; use `darwinConfigurations` instead.
- **User-level configuration is managed via Home Manager as a nix-darwin module.**
- **Host-specific logic** should go in `home/hosts/<hostname>.nix` and shared logic in `home/modules/`.
- **Packages** for each system are defined in `mkPackagesFor` in `flake.nix`.
- **Username and home directory** are set in the host file and referenced in the darwin module.

## Examples
- To add a new package for all macOS hosts, update `mkPackagesFor` in `flake.nix`.
- To add a new host, create a new file in `home/hosts/` and add a corresponding entry in `darwinConfigurations` in `flake.nix`.
- To add a shared configuration, create a module in `home/modules/` and import it in the relevant host file.

## Integration Points
- **nix-darwin**: System-level macOS configuration, including Home Manager as a module.
- **Home Manager**: User-level configuration, dotfiles, and packages.
- **Nixpkgs**: Source of all packages and system tools.

## Troubleshooting
- If a configuration fails, check the relevant host file and shared modules for errors.
- Use `nix flake check` to validate the flake.
- For macOS, always use `darwin-rebuild` for system changes, not `home-manager switch`.

## References
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [home-manager](https://github.com/nix-community/home-manager)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
