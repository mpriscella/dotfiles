# Dotfiles

Cross-platform dotfiles managed with Nix, Nix Darwin, and Home Manager. Supports
macOS and Linux with host-specific configurations.

## Requirements

- [Nix](https://nixos.org/download/) (multi-user/daemon install, with flakes
  enabled — or just run `./install.sh`, which handles both)

## Quick Start

On a bare machine (installs Nix, clones the repo, applies the configuration):

```bash
curl -fsSL https://raw.githubusercontent.com/mpriscella/dotfiles/main/install.sh | bash
```

On a machine that already has Nix:

```bash
nix run github:mpriscella/dotfiles#install
```

Or manually (the clone path matters: `programs.nh` sets `NH_FLAKE` to
`~/workspace/mpriscella/dotfiles`, so `nh` finds the flake from any directory
only if the checkout is there):

```bash
git clone https://github.com/mpriscella/dotfiles.git ~/workspace/mpriscella/dotfiles
cd ~/workspace/mpriscella/dotfiles

nix develop

# macOS (nix-darwin)
darwin-rebuild switch --flake .#<hostname>

# Linux (home-manager only)
home-manager switch --flake .#<configuration-name>
```

## Common Commands

```bash
# Apply configuration changes
darwin-rebuild switch --flake .#<hostname>      # macOS
home-manager switch --flake .#<configuration>   # Linux

# Test before applying
home-manager build --flake .#<configuration>
nix flake check

# Update dependencies
nix flake update

# Enter development shell
nix develop

# Format Nix code (scope paths to avoid recursing into nvim cache dirs)
nix fmt flake.nix home-manager nix-darwin
```

## Documentation

| Topic                                    | Description                                                    |
| ---------------------------------------- | -------------------------------------------------------------- |
| [Nix Flakes](docs/nix-flakes.md)         | Flake structure, configurations, and switching between setups  |
| [Secrets Management](docs/secrets.md)    | sops-nix setup, adding secrets, and token rotation             |
| [GPG Signing](docs/gpg.md)               | GPG key generation and Git commit signing                      |
| [Infrastructure](docs/infrastructure.md) | Terraform, Helm, and Kubernetes YAML in Neovim                 |
| [Zig](docs/zig.md)                       | Toolchain management and pinning Zig per project (zig-overlay) |
| [Slidev](docs/slidev.md)                 | Per-deck markdownlint/prettier config for Slidev projects      |

## Templates

Flake templates live in [mpriscella/nix-templates](https://github.com/mpriscella/nix-templates).
A flake registry alias (`nix.registry.templates` in `home-manager/home.nix`)
shortens usage to:

```bash
nix flake init -t templates#<template>
```

To see the available templates:

```bash
nix flake show templates
```

## Available Configurations

### nix-darwin (macOS)

| Configuration    | System         | Username   |
| ---------------- | -------------- | ---------- |
| `macbook-pro-m5` | aarch64-darwin | mpriscella |

### Home Manager (Linux)

| Configuration | System        | Username   |
| ------------- | ------------- | ---------- |
| `linux`       | x86_64-linux  | mpriscella |
| `linux-arm`   | aarch64-linux | mpriscella |

### Home Manager (Codespaces / dev containers)

A deliberately small profile: Neovim and its language servers, fish, starship,
git, and jj — no secrets, no GPG signing, no cloud tooling. `install.sh` picks
it automatically when `$CODESPACES` is set.

| Configuration    | System        | Username  |
| ---------------- | ------------- | --------- |
| `codespaces`     | x86_64-linux  | codespace |
| `codespaces-arm` | aarch64-linux | codespace |

The username must match the container's user. The GitHub-provided Codespaces
images run as `codespace`; a devcontainer that runs as `vscode` or `node` needs
its own entry in `flake.nix`.

## Project Structure

```
.
├── flake.nix              # Flake definition and configurations
├── home-manager/          # Home Manager modules
│   ├── home.nix           # Main home configuration
│   ├── codespaces.nix     # Minimal profile for Codespaces / dev containers
│   ├── modules/           # Cross-profile modules (neovim, php)
│   └── programs/          # Program-specific configs
├── nix-darwin/            # nix-darwin system configuration
├── config/                # Application configs (nvim, ghostty, etc.)
├── agents/                # Claude Code subagent definitions
├── skills/                # Claude Code skill definitions
├── secrets/               # Encrypted secrets (sops)
└── docs/                  # Documentation
```
