#!/bin/bash

set -e

# Check if dotfiles installation should be skipped
if [[ "${DEBUG_DOTFILES:-}" == "true" ]]; then
  echo "🚫 DEBUG_DOTFILES is set to 'true' - skipping dotfiles installation"
  echo "   This is useful for debugging devcontainer setups without installing dotfiles"
  echo "   To install dotfiles, unset DEBUG_DOTFILES or set it to 'false'"
  exit 0
fi

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
}

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
}

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

    # TODO: Update this command based off host machine.
    if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --determinate; then
      log_success "✓ Nix installation completed successfully"

      # shellcheck source=/dev/null
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    else
      log_error "✗ Nix installation failed"
      exit 1
    fi
  fi
}

install_dotfiles() {
  sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin/nix-darwin-25.05 -- switch --flake .#dotfiles-utm
}

main() {
  log_info "Starting dotfiles installation..."

  check_prerequisites

  install_nix

  install_dotfiles
}

main "$@"
