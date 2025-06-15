#!/bin/bash

set -e # Exit on any error

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
    # Detect Linux distribution
    if [[ -f /etc/os-release ]]; then
      source /etc/os-release
      DISTRO="$ID"
      log_info "Detected Linux distribution: $PRETTY_NAME"
    else
      DISTRO="unknown"
      log_warning "Could not detect Linux distribution"
    fi
    ;;
  *)
    log_error "Unsupported operating system: $(uname -s)"
    log_error "This script supports macOS and Linux only"
    exit 1
    ;;
  esac
}

# Check prerequisites based on OS
check_prerequisites() {
  case "$OS" in
  linux)
    # Check if curl is available
    if ! command -v curl >/dev/null 2>&1; then
      log_error "curl is required but not installed"
      log_info "Please install curl first:"
      case "$DISTRO" in
      ubuntu | debian)
        log_info "  sudo apt update && sudo apt install curl"
        ;;
      fedora | rhel | centos)
        log_info "  sudo dnf install curl"
        ;;
      arch | manjaro)
        log_info "  sudo pacman -S curl"
        ;;
      *)
        log_info "  Please install curl using your distribution's package manager"
        ;;
      esac
      exit 1
    fi

    # Check if systemd is available for multi-user install
    if command -v systemctl >/dev/null 2>&1; then
      SYSTEMD_AVAILABLE=true
      log_info "systemd detected - will use multi-user installation"
    else
      SYSTEMD_AVAILABLE=false
      log_warning "systemd not detected - will use single-user installation"
    fi
    ;;
  macos)
    # macOS specific checks
    if ! command -v curl >/dev/null 2>&1; then
      log_error "curl is required but not installed"
      exit 1
    fi
    ;;
  esac
}

# Install Nix if not already installed
install_nix() {
  if command -v nix >/dev/null 2>&1; then
    log_success "Nix is already installed"
    nix --version
    return 0
  fi

  log_info "Installing Nix..."

  case "$OS" in
  macos)
    # Use the official Nix installer for macOS with daemon support
    install_args="--daemon"
    ;;
  linux)
    # Check if we should use multi-user or single-user install
    if command -v systemctl >/dev/null 2>&1 && [[ "$EUID" -ne 0 ]]; then
      log_info "Using multi-user installation (recommended)"
      install_args="--daemon"
    else
      log_info "Using single-user installation"
      install_args=""
    fi
    ;;
  esac

  # Download and run the installer
  if curl -L https://nixos.org/nix/install | sh -s -- $install_args; then
    log_success "Nix installation completed"

    # Source nix profile to make nix available in current session
    case "$OS" in
    macos | linux)
      # Try daemon profile first (multi-user install)
      if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        log_info "Sourced Nix daemon profile"
      # Fallback to single-user profile
      elif [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
        log_info "Sourced Nix single-user profile"
      fi
      ;;
    esac

    # Verify installation
    if command -v nix >/dev/null 2>&1; then
      log_success "Nix is now available: $(nix --version)"
    else
      log_warning "Nix installed but not available in current session. Please restart your terminal."
    fi
  else
    log_error "Failed to install Nix"
    exit 1
  fi
}

# Install home-manager
install_home_manager() {
  # Check if home-manager is already installed
  if command -v home-manager >/dev/null 2>&1; then
    log_success "home-manager is already installed"
    home-manager --version
    return 0
  fi

  log_info "Installing home-manager..."

  # Add home-manager channel
  if nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager; then
    log_success "Added home-manager channel"
  else
    log_error "Failed to add home-manager channel"
    exit 1
  fi

  # Update channels
  log_info "Updating Nix channels..."
  if nix-channel --update; then
    log_success "Updated Nix channels"
  else
    log_error "Failed to update Nix channels"
    exit 1
  fi

  # Install home-manager
  log_info "Installing home-manager package..."
  if nix-shell '<home-manager>' -A install; then
    log_success "home-manager installation completed"

    # Verify installation
    if command -v home-manager >/dev/null 2>&1; then
      log_success "home-manager is now available: $(home-manager --version)"
    else
      log_warning "home-manager installed but not available in current session. Please restart your terminal."
    fi
  else
    log_error "Failed to install home-manager"
    exit 1
  fi
}

# Setup initial home-manager configuration
setup_home_manager() {
  local config_dir="$HOME/.config/home-manager"
  local dotfiles_config_dir
  dotfiles_config_dir="$(pwd)/.config/home-manager"

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
      log_info "You can now run: home-manager switch --file .config/home-manager/hosts/work-macbook-pro.nix"
      ;;
    linux)
      log_info "You can now run: home-manager switch --file .config/home-manager/hosts/linux-machine.nix"
      log_warning "Note: You may need to create a Linux-specific configuration file"
      ;;
    esac
  else
    log_warning "No home-manager configuration found in dotfiles"
    log_info "You may need to create a home-manager configuration"
  fi
}

# Main installation process
main() {
  log_info "Starting dotfiles installation..."

  # Detect operating system
  detect_os

  # Check prerequisites
  check_prerequisites

  # Install Nix
  install_nix

  # Install home-manager
  install_home_manager

  # Setup home-manager
  setup_home_manager

  log_success "Installation completed!"
  echo
  log_info "Next steps:"

  case "$OS" in
  macos)
    echo "  1. Restart your terminal or run: source ~/.zshrc (or ~/.bashrc)"
    echo "  2. Navigate to your dotfiles directory"
    echo "  3. Run: home-manager switch --file .config/home-manager/hosts/work-macbook-pro.nix"
    ;;
  linux)
    echo "  1. Restart your terminal or add Nix to your PATH:"
    echo "     source ~/.nix-profile/etc/profile.d/nix.sh (single-user)"
    echo "     source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh (multi-user)"
    echo "  2. Navigate to your dotfiles directory"
    echo "  3. Create a Linux configuration file or adapt existing one"
    echo "  4. Run: home-manager switch --file .config/home-manager/hosts/linux-machine.nix"
    ;;
  esac

  echo
  log_info "Useful commands:"
  echo "  - Update packages: nix-channel --update && home-manager switch"
  echo "  - List generations: home-manager generations"
  echo "  - Rollback: home-manager switch --switch-generation <number>"
  echo "  - Check system: nix-info -m"
}

# Run main function
main "$@"
