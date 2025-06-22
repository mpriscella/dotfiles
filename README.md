# Dotfiles

Cross-platform dotfiles managed with Nix and Home Manager, supporting macOS and
Linux with host-specific configurations.

## Components

This dotfiles repository includes:

- **Home Manager**: User-level packages, dotfiles, and shell configuration
- **nix-darwin** (macOS only): System-level macOS configuration and Homebrew management
- **GPG Configuration**: Git commit signing setup with per-host key support

## Quick Setup

### Using Nix Flakes (Recommended)

This repository uses Nix flakes for reproducible, multi-system configurations:

```bash
# 1. Install Nix with flake support
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Clone this repository
git clone https://github.com/mpriscella/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

# 3. Enter the development shell (optional, provides helpful tools)
nix develop

# 4. Apply your configuration (choose your host)
# For work MacBook Pro:
home-manager switch --flake .#work-macbook-pro

# For default/devcontainer setup:
home-manager switch --flake .#default

# For generic MacBook Air:
home-manager switch --flake .#macbook-air

# For Linux user:
home-manager switch --flake .#linux-user
```

### Legacy Setup (Non-Flake)

#### macOS with nix-darwin

For complete macOS system management:

```bash
# 1. Install Nix (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Clone this repository
git clone https://github.com/mpriscella/dotfiles.git ~/.config

# 3. Install nix-darwin (includes Home Manager)
cd ~/.config/nix-darwin
./install.sh

# 4. Restart your terminal or reload shell
exec $SHELL
```

#### Home Manager Only

For user-level configuration only:

```bash
# 1. Install Nix and Home Manager
# 2. Clone repository
git clone https://github.com/mpriscella/dotfiles.git ~/.config

# 3. Apply Home Manager configuration
home-manager switch --file ~/.config/home-manager/hosts/default.nix
```

## Management Commands

### Nix Flake Commands (Recommended)

```bash
# Apply configuration changes
home-manager switch --flake .#<configuration-name>

# Build configuration without applying (test first)
home-manager build --flake .#<configuration-name>

# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Show available configurations
nix flake show

# Check flake validity
nix flake check

# Enter development shell with tools
nix develop

# Format Nix code
nix fmt
```

**Available configurations:**
- `work-macbook-pro` - Work MacBook Pro (Apple Silicon)
- `default` - Default/devcontainer setup
- `macbook-air` - Generic MacBook Air
- `linux-user` - Alternative Linux setup

### Legacy Commands

#### nix-darwin (macOS System)
- `dr` - Apply system configuration changes
- `drb` - Build configuration without applying
- `drc` - Check configuration validity

#### Home Manager (User Configuration)
- `hms` - Apply user configuration changes
- `hmb` - Build user configuration without applying
- `hm` - Home Manager command

## Nix Flakes Configuration

This repository uses Nix flakes for reproducible, declarative configuration management across multiple systems and architectures.

### Flake Structure

The flake configuration supports:
- **Multiple systems**: x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin
- **Multiple hosts**: Different configurations for work, personal, and development environments
- **Reproducible builds**: Locked dependency versions via `flake.lock`
- **Development environment**: Built-in dev shell with helpful tools

### Available Configurations

| Configuration | System | Username | Use Case |
|---------------|---------|----------|----------|
| `work-macbook-pro` | aarch64-darwin | michaelpriscella | Work MacBook Pro (Apple Silicon) |
| `macbook-air` | aarch64-darwin | user | Personal MacBook Air |
| `default` | x86_64-linux | vscode | Devcontainers, CI/CD |
| `linux-user` | x86_64-linux | user | General Linux setup |

### Switching Configurations

```bash
# Switch to work setup
home-manager switch --flake .#work-macbook-pro

# Switch to personal setup
home-manager switch --flake .#macbook-air

# Switch to development/container setup
home-manager switch --flake .#default
```

### Updating Dependencies

```bash
# Update all flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# View current lock file info
nix flake metadata
```

### Testing Changes

```bash
# Build without applying (test configuration)
home-manager build --flake .#work-macbook-pro

# Check flake for errors
nix flake check

# Show what would be installed/removed
home-manager switch --flake .#work-macbook-pro --dry-run
```

### Development Environment

The flake includes a development shell with helpful tools:

```bash
# Enter development shell
nix develop

# Or with direnv (if .envrc is present)
direnv allow  # automatically loads when entering directory
```

The development shell includes:
- Home Manager binary
- Git
- Nix Language Server (nil)
- Helpful command examples

### Customizing Configurations

Each host configuration is in a separate file:
- `hosts/work-macbook-pro-flake.nix` - Work-specific settings
- `hosts/macbook-air-flake.nix` - Personal settings
- `hosts/default-flake.nix` - Development/container settings

Common configuration is shared via:
- `common-flake.nix` - Shared packages and settings
- `modules/machine-config-flake.nix` - Reusable options and helper scripts

### Migrating from Legacy Setup

If you're currently using the non-flake setup:

```bash
# 1. Backup current generation (optional)
home-manager generations

# 2. Switch to flake version
home-manager switch --flake .#work-macbook-pro

# 3. Verify everything works as expected
```

The flake configurations are compatible with the legacy ones but provide additional benefits:
- Reproducible builds across machines
- Easy switching between different setups
- Locked dependency versions
- Better development experience

## GPG Setup for Git Signing

This repository includes GPG commit signing configuration. Follow these steps to
set up GPG keys for signing your Git commits.

### Prerequisites

Ensure you have GPG installed:
```bash
# Check if GPG is available
gpg --version

# If using this dotfiles setup, GPG is included in the Nix packages
```

### 1. Generate a New GPG Key

```bash
# Start the key generation process
gpg --full-generate-key
```

Follow the prompts:

1. **Key type**: Select `RSA and RSA` (option 1)
2. **Key size**: Enter `4096` for maximum security
3. **Expiration**: Choose based on your security policy:
   - `0` = key does not expire (not recommended)
   - `2y` = expires in 2 years (recommended)
   - `1y` = expires in 1 year
4. **Real name**: Enter your full name (e.g., "Mike Priscella")
5. **Email**: Enter the email associated with your Git commits
6. **Comment**: Optional, can leave blank
7. **Passphrase**: Choose a strong passphrase (you'll need this for signing)

### 2. List Your GPG Keys

```bash
# List all secret keys with long format key IDs
gpg --list-secret-keys --keyid-format=long

# Or use the provided alias
gpg-list
```

Output will look like:
```
sec   rsa4096/ABC123DEF456 2025-06-18 [SC] [expires: 2027-06-18]
      1234567890ABCDEF1234567890ABCDEF12345678
uid                 [ultimate] Mike Priscella <mpriscella@gmail.com>
ssb   rsa4096/XYZ789UVW012 2025-06-18 [E] [expires: 2027-06-18]
```

Your **GPG Key ID** is `ABC123DEF456` (the part after `rsa4096/`).

### 3. Export Your Public Key

```bash
# Export your public key (replace with your actual key ID)
gpg --armor --export ABC123DEF456

# Or use the provided alias
gpg-export ABC123DEF456
```

Copy the entire output (including `-----BEGIN PGP PUBLIC KEY BLOCK-----` and `-----END PGP PUBLIC KEY BLOCK-----`).

### 4. Add Public Key to GitHub

1. Go to [GitHub Settings → SSH and GPG keys](https://github.com/settings/keys)
2. Click **"New GPG key"**
3. Paste your public key
4. Click **"Add GPG key"**

### 5. Configure Your Dotfiles

Update your host-specific configuration file with your GPG key ID:

#### For Flake Setup (Recommended)

**For work machine** (`.config/home-manager/hosts/work-macbook-pro-flake.nix`):
```nix
myConfig = {
  configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/work-macbook-pro-flake.nix";
  gpgSigningKey = "ABC123DEF456"; # Replace with your work key ID
};
```

**For personal machine** (`.config/home-manager/hosts/macbook-air-flake.nix`):
```nix
myConfig = {
  configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/macbook-air-flake.nix";
  gpgSigningKey = "XYZ789UVW012"; # Replace with your personal key ID
};
```

#### For Legacy Setup

**For work machine** (`.config/home-manager/hosts/work-macbook-pro.nix`):
```nix
myConfig = {
  configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/work-macbook-pro.nix";
  gpgSigningKey = "ABC123DEF456"; # Replace with your work key ID
};
```

**For personal machine** (`.config/home-manager/hosts/macbook-air.nix`):
```nix
myConfig = {
  configPath = "${config.home.homeDirectory}/.config/home-manager/hosts/macbook-air.nix";
  gpgSigningKey = "XYZ789UVW012"; # Replace with your personal key ID
};
```

### 6. Apply Configuration

#### Using Flakes (Recommended)
```bash
# Apply flake configuration
home-manager switch --flake .#work-macbook-pro

# Or for other configurations
home-manager switch --flake .#macbook-air
home-manager switch --flake .#default
```

#### Using Legacy Setup
```bash
# Rebuild and apply your Home Manager configuration
home-manager switch

# Or if using a specific host file
home-manager switch --file .config/home-manager/hosts/work-macbook-pro.nix
```

### 7. Test GPG Signing

```bash
# Test GPG functionality
echo "test" | gpg --clearsign

# Make a test commit
git commit --allow-empty -m "Test GPG signing"

# Verify the commit is signed
git log --show-signature -1
```

You should see output like:
```
gpg: Signature made Wed Jun 18 10:30:00 2025 PDT
gpg:                using RSA key ABC123DEF456
gpg: Good signature from "Mike Priscella <mpriscella@gmail.com>"
```

### Multiple Keys for Different Contexts

This dotfiles setup supports different GPG keys for different machines:

- **Work Machine**: Use your work email and work GPG key
- **Personal Machine**: Use your personal email and personal GPG key
- **Default/Testing**: Can be set to `null` to disable signing

### GPG Key Management Commands

The dotfiles include helpful aliases:

```bash
# List all secret keys
gpg-list

# Export a public key
gpg-export KEY_ID

# Restart GPG agent (if having issues)
gpg-restart

# Edit a key (change expiration, add email, etc.)
gpg --edit-key KEY_ID
```

### Troubleshooting

**GPG agent not starting:**
```bash
# Restart the GPG agent
gpg-restart

# Or manually
gpg-connect-agent reloadagent /bye
```

**Passphrase prompts:**
- The configuration caches your passphrase for 12 hours
- You'll only need to enter it once per session

**Commits not showing as verified:**
- Ensure your email in Git config matches the email in your GPG key
- Check that your public key is added to GitHub
- Verify the key ID is correct in your configuration

**Key expiration:**
```bash
# Extend key expiration
gpg --edit-key KEY_ID
gpg> expire
gpg> save

# Re-export and update on GitHub
gpg-export KEY_ID
```

### Security Best Practices

1. **Use a strong passphrase** for your GPG key
2. **Set key expiration** (1-2 years recommended)
3. **Backup your keys securely**:
   ```bash
   # Export private key for backup (store securely!)
   gpg --export-secret-keys --armor KEY_ID > private-key-backup.asc
   ```
4. **Use different keys** for work and personal contexts
5. **Revoke compromised keys** immediately:
   ```bash
   gpg --gen-revoke KEY_ID > revocation-cert.asc
   ```

### References

- [GitHub GPG Documentation](https://docs.github.com/en/authentication/managing-commit-signature-verification)
- [GnuPG Documentation](https://gnupg.org/documentation/)
- [Git Signing Documentation](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
