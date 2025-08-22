#!/bin/bash

set -e

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

    detect_os
    detect_container

    INSTALL_COMMAND="curl -fsSL https://install.determinate.systems/nix | sh -s -- install"

    if [[ "$OS" == "linux" ]]; then
      if [[ $IN_CONTAINER ]]; then
        INSTALL_COMMAND="curl -fsSL https://install.determinate.systems/nix | sh -s -- install linux --no-confirm --init none"
      fi
    fi

    if eval "$INSTALL_COMMAND"; then
      log_success "✓ Nix installation completed successfully"

      # shellcheck source=/dev/null
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' # Does this change based off the OS?
    else
      log_error "✗ Nix installation failed"
      exit 1
    fi
  fi
}

main() {
  log_info "Starting dotfiles installation..."

  check_prerequisites

  install_nix
}

main "$@"
