#!/bin/bash

set -e

DOTFILES_REPO="https://github.com/mpriscella/dotfiles.git"
# Track whether DOTFILES_DIR was set explicitly, so local-checkout detection
# doesn't override a deliberate override.
DOTFILES_DIR_EXPLICIT="${DOTFILES_DIR:+true}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config/dotfiles}"

# Identity used when generating a GPG signing key. Must match `userConfig` in
# flake.nix — git/jujutsu resolve the signing key from this email, so a key
# with this uid is what enables commit signing.
GIT_NAME="Mike Priscella"
GIT_EMAIL="mpriscella@gmail.com"

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

  # The Nix installer unpacks its binary tarball with `tar -xJf`. On macOS the
  # stock libarchive `tar` decompresses xz in-process, so no `xz` binary is
  # needed; on Linux, GNU tar shells out to the external `xz` binary. This
  # mirrors the upstream nixos.org/nix/install prerequisite check.
  if [[ "$(uname -s)" != "Darwin" ]] && ! command -v xz >/dev/null 2>&1; then
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
# When run from inside a checkout of the dotfiles repo (e.g. `./install.sh`),
# apply that checkout so local edits are used instead of cloning the remote.
# The curl | bash bootstrap has no script file on disk, so it falls through to
# the clone path. An explicit DOTFILES_DIR always wins.
# Globals:
#   DOTFILES_DIR, DOTFILES_DIR_EXPLICIT, LOCAL_CHECKOUT
#######################################
resolve_dotfiles_dir() {
  LOCAL_CHECKOUT=false

  [[ -n "$DOTFILES_DIR_EXPLICIT" ]] && return

  local src="${BASH_SOURCE[0]:-}"
  [[ -n "$src" && -f "$src" ]] || return

  local script_dir
  script_dir="$(cd "$(dirname "$src")" >/dev/null 2>&1 && pwd)" || return

  if [[ -f "$script_dir/flake.nix" ]]; then
    DOTFILES_DIR="$script_dir"
    LOCAL_CHECKOUT=true
    log_info "Using local dotfiles checkout at $DOTFILES_DIR"
  fi
}

#######################################
# Clone the dotfiles repository if not already present. Skipped when a local
# checkout was resolved.
# Globals:
#   DOTFILES_REPO, DOTFILES_DIR, LOCAL_CHECKOUT
#######################################
clone_dotfiles() {
  if [[ "$LOCAL_CHECKOUT" == true ]]; then
    return
  fi

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

  # Pass experimental features as a flag rather than relying on NIX_CONFIG:
  # `sudo` resets the environment by default, so an exported NIX_CONFIG would
  # not reach the darwin-rebuild invocation below.
  local nix_features=(--extra-experimental-features "nix-command flakes")

  if [[ "$OS" == "macos" ]]; then
    # `sudo nix run` evaluates the flake as root, but the checkout is owned by
    # the invoking user; mark it safe so git/nix don't reject it as "dubious
    # ownership". Guarded so re-runs don't append duplicate entries.
    if ! sudo git config --global --get-all safe.directory 2>/dev/null | grep -qxF "$DOTFILES_DIR"; then
      sudo git config --global --add safe.directory "$DOTFILES_DIR"
    fi

    log_info "Applying nix-darwin configuration '$CONFIGURATION'..."
    sudo nix run "${nix_features[@]}" github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake ".#$CONFIGURATION"
  else
    log_info "Applying Home Manager configuration '$CONFIGURATION'..."
    nix run "${nix_features[@]}" github:nix-community/home-manager -- switch --flake ".#$CONFIGURATION"
  fi

  log_success "✓ Configuration '$CONFIGURATION' applied"
}

#######################################
# Locate the gpg binary provided by the freshly applied configuration. The Nix
# user profile isn't on this script's PATH yet, so probe known locations.
# Outputs:
#   Path to gpg on stdout; returns non-zero if not found.
#######################################
find_gpg() {
  if command -v gpg >/dev/null 2>&1; then
    command -v gpg
    return 0
  fi

  local candidate
  for candidate in \
    "/etc/profiles/per-user/$USER/bin/gpg" \
    "$HOME/.nix-profile/bin/gpg"; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

#######################################
# Generate a GPG signing key if none matching GIT_EMAIL exists. git/jujutsu
# resolve the signing key from the committer email, so any key with this uid
# enables commit signing without a rebuild. Interactive, so gpg-agent/pinentry
# can prompt for a passphrase to protect the key. Non-fatal on failure.
# Globals:
#   GIT_NAME, GIT_EMAIL
#######################################
ensure_gpg_key() {
  local gpg
  if ! gpg="$(find_gpg)"; then
    log_warning "gpg not found on PATH; skipping signing key generation."
    log_warning "Open a new shell and run: gpg --quick-generate-key \"$GIT_NAME <$GIT_EMAIL>\" default default 2y"
    return 0
  fi

  if "$gpg" --list-secret-keys "$GIT_EMAIL" >/dev/null 2>&1; then
    log_info "GPG signing key for $GIT_EMAIL already exists."
    return 0
  fi

  log_info "No GPG signing key found for $GIT_EMAIL; generating one..."
  log_info "You'll be prompted for a passphrase to protect the key."
  if "$gpg" --quick-generate-key "$GIT_NAME <$GIT_EMAIL>" default default 2y; then
    log_success "✓ Generated GPG signing key for $GIT_EMAIL"
  else
    log_warning "GPG key generation failed; commit signing won't work until a key exists."
  fi
}

main() {
  log_info "Starting dotfiles installation..."

  check_prerequisites
  detect_os

  install_nix

  # Upstream Nix doesn't enable flakes by default. `apply_configuration` passes
  # the experimental features directly to `nix run` (see the note there about
  # why NIX_CONFIG can't be used with `sudo`).

  resolve_dotfiles_dir
  clone_dotfiles
  detect_configuration "${1:-}"
  apply_configuration

  # gpg/pinentry are provided by the configuration just applied, so this must
  # run afterward.
  ensure_gpg_key
}

main "$@"
