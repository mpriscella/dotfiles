#!/bin/bash

set -e

DOTFILES_REPO="https://github.com/mpriscella/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config/dotfiles}"

#######################################
# Logging Functions.
#######################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

#######################################
# Check prerequisites.
# Arguments:
#   None
#######################################
check_prerequisites() {
  if ! command -v curl >/dev/null 2>&1; then
    log_error "curl is required but not installed"
    exit 1
  fi

  if ! command -v xz >/dev/null 2>&1; then
    log_error "xz is required but not installed"
    exit 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    log_error "git is required but not installed"
    exit 1
  fi
}

#######################################
# Detect the host operating system.
# Arguments:
#   None
#######################################
detect_os() {
  case "$(uname -s)" in
  Darwin*)
    OS="macos"
    ;;
  Linux*)
    OS="linux"
    ;;
  *)
    log_error "Unsupported operating system: $(uname -s)"
    exit 1
    ;;
  esac
  log_info "$OS detected."
}

#######################################
# Determine whether host system is a container.
# Arguments:
#   None
#######################################
detect_container() {
  IN_CONTAINER=false
  if [[ -f /.dockerenv ]] || [[ -n "${CODESPACES:-}" ]] || [[ -n "${DEVCONTAINER:-}" ]] || grep -qi 'docker\|lxc\|container' /proc/1/cgroup 2>/dev/null; then
    IN_CONTAINER=true
    log_info "Container environment detected"
  fi
}

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    log_info "Nix is already installed: $(nix --version)"
    log_info "Skipping Nix installation."
  else
    log_info "Installing Nix..."

    detect_container

    INSTALL_COMMAND="curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon --yes"

    if [[ "$OS" == "linux" ]]; then
      if [[ "$IN_CONTAINER" == true ]]; then
        # Single-user install: containers typically lack an init system for
        # the daemon.
        INSTALL_COMMAND="curl -fsSL https://nixos.org/nix/install | sh -s -- --no-daemon --yes"
      fi
    fi

    if eval "$INSTALL_COMMAND"; then
      log_success "✓ Nix installation completed successfully"

      # Multi-user (daemon) and single-user installs use different profile
      # scripts.
      # shellcheck source=/dev/null
      if [[ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      elif [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
    else
      log_error "✗ Nix installation failed"
      exit 1
    fi
  fi
}

#######################################
# Clone the dotfiles repository if not already present.
# Globals:
#   DOTFILES_REPO, DOTFILES_DIR
#######################################
clone_dotfiles() {
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    log_info "Dotfiles already cloned at $DOTFILES_DIR."
  else
    log_info "Cloning dotfiles to $DOTFILES_DIR..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

#######################################
# Determine which flake configuration to apply.
# Arguments:
#   Optional configuration name (overrides detection)
#######################################
detect_configuration() {
  if [[ -n "${1:-}" ]]; then
    CONFIGURATION="$1"
    return
  fi

  if [[ "$OS" == "macos" ]]; then
    CONFIGURATION="$(scutil --get LocalHostName | tr '[:upper:]' '[:lower:]')"
    log_info "Detected configuration '$CONFIGURATION' from hostname."
    log_info "If this doesn't match a flake configuration, re-run with: ./install.sh <configuration>"
  else
    case "$(uname -m)" in
    aarch64 | arm64)
      CONFIGURATION="linux-arm"
      ;;
    *)
      CONFIGURATION="linux"
      ;;
    esac
  fi
}

#######################################
# Apply the flake configuration with nix-darwin or Home Manager.
# Globals:
#   OS, DOTFILES_DIR, CONFIGURATION
#######################################
apply_configuration() {
  cd "$DOTFILES_DIR"

  if [[ "$OS" == "macos" ]]; then
    log_info "Applying nix-darwin configuration '$CONFIGURATION'..."
    sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake ".#$CONFIGURATION"
  else
    log_info "Applying Home Manager configuration '$CONFIGURATION'..."
    nix run github:nix-community/home-manager -- switch --flake ".#$CONFIGURATION"
  fi

  log_success "✓ Configuration '$CONFIGURATION' applied"
}

main() {
  log_info "Starting dotfiles installation..."

  check_prerequisites
  detect_os

  install_nix

  # Upstream Nix doesn't enable flakes by default; the bootstrap below relies
  # on `nix run`.
  export NIX_CONFIG="experimental-features = nix-command flakes"

  clone_dotfiles
  detect_configuration "${1:-}"
  apply_configuration
}

main "$@"
