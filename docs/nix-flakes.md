# Nix Flakes Configuration

This repository uses Nix flakes for reproducible, declarative configuration
management across multiple systems and architectures.

## Flake Structure

The flake configuration supports:

- **Multiple systems**: x86_64-linux, aarch64-linux, aarch64-darwin
- **Multiple hosts**: Different configurations for work, personal, and development environments
- **Reproducible builds**: Locked dependency versions via `flake.lock`
- **Development environment**: Built-in dev shell with helpful tools
- **Secrets management**: Integrated sops-nix for encrypted secrets

## Available Configurations

### nix-darwin (macOS)

These configurations use `darwin-rebuild` and include both system-level (nix-darwin) and user-level (home-manager) configuration.

| Configuration    | System         | Username         | Use Case        |
| ---------------- | -------------- | ---------------- | --------------- |
| `macbook-pro-m5` | aarch64-darwin | mpriscella       | Personal M5 Mac |
| `macbook-pro-m3` | aarch64-darwin | michaelpriscella | Work M3 Mac     |
| `macbook-air-m4` | aarch64-darwin | mpriscella       | Personal M4 Mac |

### Home Manager (Linux)

These configurations use `home-manager` standalone for user-level configuration only.

| Configuration | System        | Username   | Use Case              |
| ------------- | ------------- | ---------- | --------------------- |
| `linux`       | x86_64-linux  | mpriscella | x86_64 Linux machines |
| `linux-arm`   | aarch64-linux | mpriscella | ARM64 Linux machines  |

## Applying Configurations

### macOS (nix-darwin)

```bash
# Build and apply system + user configuration
darwin-rebuild switch --flake .#macbook-pro-m5

# Build without applying (test first)
darwin-rebuild build --flake .#macbook-pro-m5

# Rollback to previous generation
darwin-rebuild switch --rollback
```

### Linux (home-manager)

```bash
# Apply user configuration
home-manager switch --flake .#linux

# Build without applying
home-manager build --flake .#linux

# Rollback to previous generation
home-manager switch --rollback
```

## Updating Dependencies

```bash
# Update all flake inputs (nixpkgs, home-manager, sops-nix, etc.)
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# View current lock file info
nix flake metadata
```

## Testing Changes

```bash
# Check flake for errors
nix flake check

# Build without applying (nix-darwin)
darwin-rebuild build --flake .#macbook-pro-m5

# Build without applying (home-manager)
home-manager build --flake .#linux

# Dry run to see what would change
home-manager switch --flake .#linux --dry-run
```

## Development Environment

The flake includes a development shell with helpful tools:

```bash
# Enter development shell
nix develop

# Or with direnv (if .envrc is present)
direnv allow  # automatically loads when entering directory
```

The development shell includes:

- Home Manager binary
- darwin-rebuild (on macOS)
- nvim-dev script for isolated Neovim testing
- Helpful command examples displayed on entry

## Project Structure

```
.
├── flake.nix                    # Flake definition, inputs, and configurations
├── flake.lock                   # Locked dependency versions
├── home-manager/
│   ├── home.nix                 # Main home-manager configuration
│   └── programs/                # Program-specific modules
│       ├── fish.nix             # Fish shell config
│       ├── git.nix              # Git config
│       ├── sops.nix             # Secrets management
│       └── ...
├── nix-darwin/
│   └── base.nix                 # macOS system configuration
├── config/                      # Application configs (nvim, ghostty)
├── secrets/                     # Encrypted secrets (sops)
└── templates/                   # Flake templates
```

## Adding a New Configuration

### New macOS Host

Add to `darwinConfigurations` in `flake.nix`:

```nix
darwinConfigurations = {
  "new-mac" = mkDarwinConfiguration {
    username = "yourusername";
    gpgSigningKey = "YOUR_GPG_KEY_ID";  # or null to disable signing
  };
};
```

### New Linux Host

Add to `homeConfigurations` in `flake.nix`:

```nix
homeConfigurations = {
  "new-linux" = mkHomeConfiguration {
    system = "x86_64-linux";  # or "aarch64-linux"
    username = "yourusername";
  };
};
```

## Flake Inputs

| Input        | Description                      |
| ------------ | -------------------------------- |
| nixpkgs      | Nix packages (nixpkgs-unstable)  |
| nix-darwin   | macOS system configuration       |
| home-manager | User environment management      |
| sops-nix     | Secrets management with age/sops |

## References

- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [nix-darwin Documentation](https://github.com/nix-darwin/nix-darwin)
- [Home Manager Documentation](https://nix-community.github.io/home-manager/)
