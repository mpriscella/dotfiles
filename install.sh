#!/bin/bash

set -e # Exit on any error

# Check if dotfiles installation should be skipped
if [[ "${DEBUG_DOTFILES:-}" == "true" ]]; then
  echo "🚫 DEBUG_DOTFILES is set to 'true' - skipping dotfiles installation"
  echo "   This is useful for debugging devcontainer setups without installing dotfiles"
  echo "   To install dotfiles, unset DEBUG_DOTFILES or set it to 'false'"
  exit 0
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Detect operating system
detect_os() {
  case "$(uname -s)" in
  Darwin*)
    OS="macos"
    log_info "Running on macOS"
    ;;
  Linux*)
    OS="linux"
    log_info "Running on Linux"
    ;;
  *)
    log_error "Unsupported operating system: $(uname -s)"
    log_error "This script supports macOS and Linux only"
    exit 1
    ;;
  esac

  # Detect if we're in a container environment
  if [[ -f /.dockerenv ]] || [[ -n "${CODESPACES:-}" ]] || [[ -n "${DEVCONTAINER:-}" ]] || grep -qi 'docker\|lxc\|container' /proc/1/cgroup 2>/dev/null; then
    IN_CONTAINER=true
    log_info "Container environment detected"
  else
    IN_CONTAINER=false
  fi
}

# Check prerequisites based on OS
check_prerequisites() {
  if ! command -v curl >/dev/null 2>&1; then
    log_error "curl is required but not installed"
    exit 1
  fi
}

# Install Nix if not already installed
# TODO:
#  - If this script is run and nix is installed, then the script is run again, it's failing because path is not updated.
install_nix() {
  # Check for permission issues in devcontainer first
  if command -v nix >/dev/null 2>&1 && [[ "$IN_CONTAINER" == true ]]; then
    # Test if we can actually use nix commands that require write access to both db and store
    write_test_failed=false

    if [[ ! -w /nix/var/nix/db/big-lock ]] 2>/dev/null || ! touch /nix/var/nix/test-write 2>/dev/null; then
      write_test_failed=true
    fi
    rm -f /nix/var/nix/test-write 2>/dev/null # Clean up test file

    # Also test if we can write to the store (where the real issues often occur)
    if ! touch /nix/store/test-write 2>/dev/null; then
      write_test_failed=true
    fi
    rm -f /nix/store/test-write 2>/dev/null # Clean up test file

    if [[ "$write_test_failed" == true ]]; then
      log_warning "Detected Nix permission issues in devcontainer"
      log_error "Nix database permissions issue detected"
      log_info "This usually happens when Nix was installed as root in devcontainer"
      log_info ""
      log_info "Solutions:"
      echo "  1. Fix database permissions (quick fix):"
      echo "     sudo chown -R $(whoami):$(whoami) /nix/var/nix/"
      echo ""
      echo "  2. Reinstall as single-user (recommended for devcontainers):"
      echo "     sudo rm -rf /nix /etc/nix"
      echo "     curl -L https://nixos.org/nix/install | sh -s -- --no-daemon"
      echo "     source ~/.bashrc"

      read -p "Choose option (1/2) or cancel (N): " -n 1 -r
      echo
      if [[ $REPLY == "1" ]]; then
        log_info "Attempting to fix Nix database permissions..."
        if sudo chown -R "$(whoami):$(whoami)" /nix/var/nix/ 2>/dev/null; then
          log_success "Fixed Nix database permissions!"
          log_warning "Note: You may still encounter issues with /nix/store. Consider option 2 for a complete fix."
        else
          log_error "Failed to fix permissions."
          exit 1
        fi
      elif [[ $REPLY == "2" ]]; then
        log_info "Reinstalling Nix as single-user..."
        if sudo rm -rf /nix /etc/nix /etc/profile.d/nix.sh 2>/dev/null; then
          log_info "Removed existing Nix installation"
          # Fall through to the installation section below
        else
          log_error "Failed to remove existing Nix installation"
          exit 1
        fi
      else
        log_error "Cannot continue with permission issues. Please fix manually."
        exit 1
      fi
    fi
  fi

  if command -v nix >/dev/null 2>&1; then
    log_success "Nix is already installed: $(nix --version)"

    # Even if Nix is installed, ensure it's sourced in current session
    if [[ -z "${NIX_PATH:-}" ]]; then
      log_info "Sourcing Nix environment for current session..."
      # Try to source Nix profile for current session
      if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
        # shellcheck source=/dev/null
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        log_info "Sourced Nix daemon profile"
      elif [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        # shellcheck source=/dev/null
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
        log_info "Sourced Nix single-user profile"
      fi
    else
      log_info "Nix environment already sourced (NIX_PATH is set)"
    fi

    log_success "Nix is ready to use"
    return 0
  fi

  log_info "Installing Nix..."

  case "$OS" in
  macos)
    if [[ "$IN_CONTAINER" == true ]]; then
      log_info "Container detected on macOS - using single-user installation"
      install_args="--no-daemon"
    else
      # Use the official Nix installer for macOS with daemon support
      install_args="--daemon"
    fi
    ;;
  linux)
    # In containers, always use single-user to avoid permission issues
    if [[ "$IN_CONTAINER" == true ]]; then
      log_info "Container environment detected - using single-user installation"
      install_args="--no-daemon"
    # Check if we should use multi-user or single-user install on bare metal
    elif command -v systemctl >/dev/null 2>&1 && [[ "$EUID" -ne 0 ]]; then
      log_info "Using multi-user installation (recommended)"
      install_args="--daemon"
    else
      log_info "Using single-user installation"
      install_args="--no-daemon"
    fi
    ;;
  esac

  # Download and run the installer
  if curl -L https://nixos.org/nix/install | sh -s -- "$install_args"; then
    log_success "Nix installation completed"

    # Source nix profile to make nix available in current session
    case "$OS" in
    macos | linux)
      # Try daemon profile first (multi-user install)
      if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
        # shellcheck source=/dev/null
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        log_info "Sourced Nix daemon profile"
      # Fallback to single-user profile
      elif [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        # shellcheck source=/dev/null
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
        log_info "Sourced Nix single-user profile"
      else
        log_warning "Could not find Nix profile to source"
      fi
      ;;
    esac

    # Verify installation
    if command -v nix >/dev/null 2>&1; then
      log_success "Nix is now available: $(nix --version)"
    else
      log_warning "Nix installed but not available in current session."
      log_info "You may need to restart your terminal or manually source the Nix profile."
      # Don't exit here - continue with the script
    fi
  else
    log_error "Failed to install Nix"
    log_info "You can try installing Nix manually from: https://nixos.org/download.html"
    exit 1
  fi
}

# Install home-manager
install_home_manager() {
  # Check if home-manager is already installed.
  if command -v home-manager >/dev/null 2>&1; then
    log_success "home-manager is already installed: $(home-manager --version)"
    return 0
  fi

  # Ensure nix-channel command is available.
  if ! command -v nix-channel >/dev/null 2>&1; then
    log_error "nix-channel command not found. Nix may not be properly installed or sourced."
    log_info "Try restarting your terminal or manually sourcing Nix profile."
    return 1
  fi

  log_info "Installing home-manager..."

  # Check if home-manager channel already exists
  if nix-channel --list | grep -q "home-manager"; then
    log_info "home-manager channel already exists"
  else
    # Add home-manager channel
    if nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager; then
      log_success "Added home-manager channel"
    else
      log_error "Failed to add home-manager channel"
      log_info "You can try adding it manually: nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager"
      return 1
    fi
  fi

  # Update channels
  log_info "Updating Nix channels..."
  if nix-channel --update; then
    log_success "Updated Nix channels"
  else
    log_warning "Failed to update Nix channels, but continuing..."
    log_info "You may need to run 'nix-channel --update' manually later"
  fi

  # Install home-manager
  log_info "Installing home-manager package..."
  if nix-shell '<home-manager>' -A install; then
    log_success "home-manager installation completed"

    # Verify installation
    if command -v home-manager >/dev/null 2>&1; then
      log_success "home-manager is now available: $(home-manager --version)"
    else
      log_warning "home-manager installed but not available in current session."
      log_info "You may need to restart your terminal or source your shell profile."
      # Don't exit here - continue with the script
    fi
  else
    log_error "Failed to install home-manager"
    log_info "You can try installing it manually:"
    echo "  1. nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager"
    echo "  2. nix-channel --update"
    echo "  3. nix-shell '<home-manager>' -A install"
    return 1
  fi
}

# Setup initial home-manager configuration
setup_home_manager() {
  local config_dir="$HOME/.config/home-manager"
  local dotfiles_config_dir
  dotfiles_config_dir="$(pwd)/.config/home-manager"
  local config_file

  if [[ -d "$config_dir" ]]; then
    log_info "home-manager config directory already exists"
  else
    log_info "Creating home-manager config directory..."
    mkdir -p "$config_dir"
  fi

  # Check if we have a dotfiles home-manager config
  if [[ -d "$dotfiles_config_dir" ]]; then
    log_info "Dotfiles home-manager configuration found"

    # Suggest appropriate configuration file based on OS
    case "$OS" in
    macos)
      config_file="work-macbook-pro.nix"
      # log_info "You can now run: home-manager switch --file .config/home-manager/hosts/work-macbook-pro.nix"
      ;;
    linux)
      config_file="default.nix"
      # log_info "You can now run: home-manager switch --file .config/home-manager/hosts/linux-machine.nix"
      ;;
    esac
    log_info "You can now run: home-manager switch --file .config/home-manager/hosts/$config_file"
  else
    log_warning "No home-manager configuration found in dotfiles"
    log_info "You may need to create a home-manager configuration"
  fi
}

# Test and apply home-manager configuration
test_and_apply_config() {
  local config_file=".config/home-manager/hosts/default.nix"
  local dotfiles_config_dir
  dotfiles_config_dir="$(pwd)/.config/home-manager"

  # Check if we're in the dotfiles directory
  if [[ ! -d "$dotfiles_config_dir" ]]; then
    log_error "Not in dotfiles directory or home-manager config not found"
    log_info "Please run this script from your dotfiles directory"
    return 1
  fi

  # Check if default.nix exists
  if [[ ! -f "$config_file" ]]; then
    log_warning "Default configuration file not found: $config_file"
    log_info "Skipping automatic configuration application"
    return 1
  fi

  log_info "Testing home-manager configuration: $config_file"

  # Test the configuration by building it
  if home-manager build --file "$config_file" --no-out-link; then
    log_success "Configuration test passed!"

    # Ask user if they want to apply it
    echo
    read -p "Do you want to apply this configuration now? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      log_info "Applying home-manager configuration..."

      if home-manager switch --file "$config_file"; then
        log_success "Home-manager configuration applied successfully!"

        # Show what was applied
        log_info "Configuration details:"
        echo "  - User: $(whoami)"
        echo "  - Config: $config_file"
        echo "  - Home: $HOME"
        echo "  - Generation: $(home-manager generations | head -1 | awk '{print $5}' || echo 'Unknown')"

        return 0
      else
        log_error "Failed to apply home-manager configuration"
        log_info "You can try manually with: home-manager switch --file $config_file"
        return 1
      fi
    else
      log_info "Configuration not applied. You can apply it later with:"
      echo "  home-manager switch --file $config_file"
      return 0
    fi
  else
    log_error "Configuration test failed!"
    log_info "Please check your configuration file: $config_file"
    log_info "Common issues:"
    echo "  - Check syntax errors in nix files"
    echo "  - Verify all imports exist"
    echo "  - Ensure username/home directory are correct"
    echo "  - Try: home-manager build --file $config_file --show-trace"
    return 1
  fi
}

# Check and fix Nix permissions in devcontainer
check_devcontainer_nix() {
  if [[ "$IN_CONTAINER" != true ]]; then
    return 0
  fi

  # Check if Nix is installed but has permission issues
  if [[ -d /nix ]] && ! nix-channel --list >/dev/null 2>&1; then
    log_warning "Detected Nix permission issues in devcontainer"

    # Check if we're running as root
    if [[ "$EUID" -eq 0 ]]; then
      log_error "Running as root in devcontainer. This script should run as the target user."
      log_info "To fix this, ensure your devcontainer runs this script as the 'vscode' user:"
      echo "  \"postCreateCommand\": \"su - vscode -c 'cd /workspaces/dotfiles && ./install.sh'\""
      exit 1
    fi

    # Check if big-lock file has permission issues
    if [[ ! -w /nix/var/nix/db/big-lock ]] 2>/dev/null; then
      log_error "Nix database permissions issue detected"
      log_info "This usually happens when Nix was installed as root in devcontainer"
      log_info ""
      log_info "Solutions:"
      echo "  1. Fix permissions (run as root):"
      echo "     sudo chown -R $(whoami):$(whoami) /nix/var/nix/"
      echo ""
      echo "  2. Or reinstall Nix as single-user:"
      echo "     sudo rm -rf /nix /etc/nix"
      echo "     curl -L https://nixos.org/nix/install | sh -s -- --no-daemon"
      echo "     source ~/.bashrc"
      echo ""
      echo "  3. Or run this script with sudo to fix ownership:"
      echo "     sudo ./install.sh"

      read -p "Would you like to automatically fix the permissions? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Attempting to fix Nix permissions..."
        if sudo chown -R "$(whoami):$(whoami)" /nix/var/nix/ 2>/dev/null; then
          log_success "Fixed Nix permissions!"
        else
          log_error "Failed to fix permissions. You may need to reinstall Nix."
          exit 1
        fi
      else
        log_error "Cannot continue with permission issues. Please fix manually."
        exit 1
      fi
    fi
  fi
}

# Main installation process
main() {
  log_info "Starting dotfiles installation..."

  # Detect operating system
  detect_os

  # Check devcontainer Nix setup
  check_devcontainer_nix

  # Check prerequisites
  check_prerequisites

  # Install Nix
  log_info "Checking Nix installation..."
  install_nix
  nix_install_result=$?

  if [[ $nix_install_result -ne 0 ]]; then
    log_error "Nix installation failed. Cannot continue."
    exit 1
  fi

  # Install home-manager
  log_info "Checking home-manager installation..."
  install_home_manager
  hm_install_result=$?

  if [[ $hm_install_result -ne 0 ]]; then
    log_warning "home-manager installation had issues, but continuing..."
    log_info "You may need to install home-manager manually later."
  fi

  # Setup home-manager
  setup_home_manager

  # Test and apply configuration (only if home-manager is available)
  if command -v home-manager >/dev/null 2>&1; then
    log_info "Testing and applying home-manager configuration..."
    if test_and_apply_config; then
      log_success "Installation and configuration completed!"
      echo
      log_info "Your dotfiles are now active!"
      echo
      log_info "Useful commands:"
      echo "  - Update packages: nix-channel --update && home-manager switch"
      echo "  - Rebuild config: home-manager switch --file .config/home-manager/hosts/default.nix"
      echo "  - List generations: home-manager generations"
      echo "  - Rollback: home-manager switch --switch-generation <number>"
      echo "  - Check system: nix-info -m"
    else
      log_warning "Configuration test/apply step had issues"
      log_success "Base installation completed!"
      echo
      log_info "Manual next steps:"

      case "$OS" in
      macos | linux)
        echo "  1. Navigate to your dotfiles directory"
        echo "  2. Test config: home-manager build --file .config/home-manager/hosts/default.nix --no-out-link"
        echo "  3. Apply config: home-manager switch --file .config/home-manager/hosts/default.nix"
        ;;
      esac

      echo
      log_info "Useful commands:"
      echo "  - Update packages: nix-channel --update && home-manager switch"
      echo "  - List generations: home-manager generations"
      echo "  - Rollback: home-manager switch --switch-generation <number>"
      echo "  - Check system: nix-info -m"
    fi
  else
    log_warning "home-manager not available. Skipping configuration application."
    log_success "Nix installation completed!"
    echo
    log_info "Next steps:"
    echo "  1. Install home-manager manually:"
    echo "     nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager"
    echo "     nix-channel --update"
    echo "     nix-shell '<home-manager>' -A install"
    echo "  2. Apply your configuration:"
    echo "     home-manager switch --file .config/home-manager/hosts/default.nix"
  fi
}

# Run main function
main "$@"
