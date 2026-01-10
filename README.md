# Dotfiles

Cross-platform dotfiles managed with Nix, Nix Darwin, and Home Manager. Supports
macOS and Linux with host-specific configurations.

## Requirements

- [Determinate Nix](https://determinate.systems/posts/determinate-nix-installer)

## Quick Start

```bash
git clone https://github.com/mpriscella/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

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

# Format Nix code
nix fmt
```

## Documentation

| Topic                                 | Description                                                   |
| ------------------------------------- | ------------------------------------------------------------- |
| [Nix Flakes](docs/nix-flakes.md)      | Flake structure, configurations, and switching between setups |
| [Secrets Management](docs/secrets.md) | sops-nix setup, adding secrets, and token rotation            |
| [GPG Signing](docs/gpg.md)            | GPG key generation and Git commit signing                     |

## Available Configurations

### nix-darwin (macOS)

| Configuration    | System         | Username         |
| ---------------- | -------------- | ---------------- |
| `macbook-pro-m5` | aarch64-darwin | mpriscella       |
| `macbook-pro-m3` | aarch64-darwin | michaelpriscella |
| `macbook-air-m4` | aarch64-darwin | mpriscella       |

### Home Manager (Linux)

| Configuration | System        | Username   |
| ------------- | ------------- | ---------- |
| `linux`       | x86_64-linux  | mpriscella |
| `linux-arm`   | aarch64-linux | mpriscella |

## Project Structure

```
.
├── flake.nix              # Flake definition and configurations
├── home-manager/          # Home Manager modules
│   ├── home.nix           # Main home configuration
│   └── programs/          # Program-specific configs
├── nix-darwin/            # nix-darwin system configuration
├── config/                # Application configs (nvim, ghostty, etc.)
├── secrets/               # Encrypted secrets (sops)
└── docs/                  # Documentation
```
