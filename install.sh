#!/bin/bash
#
# Usage: ./install.sh [--build-only] [configuration]
#
#   --build-only     Build the configuration instead of activating it. Useful
#                    for previewing what a fresh install would build, and for
#                    CI (see .github/workflows/install-test.yml).
#   configuration    Flake configuration name; detected from the hostname
#                    (macOS) or architecture (Linux) when omitted.

set -e

DOTFILES_REPO="https://github.com/mpriscella/dotfiles.git"
# Track whether DOTFILES_DIR was set explicitly, so local-checkout detection
# doesn't override a deliberate override.
# The default matches what the configuration itself assumes: programs.nh sets
# NH_FLAKE to ~/workspace/mpriscella/dotfiles, so `nh darwin switch` finds the
# flake from any directory only if the checkout is there.
DOTFILES_DIR_EXPLICIT="${DOTFILES_DIR:+true}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/workspace/mpriscella/dotfiles}"

# Identity used when generating a GPG signing key. Must match `userConfig` in
# flake.nix — git/jujutsu resolve the signing key from this email, so a key
# with this uid is what enables commit signing.
GIT_NAME="Mike Priscella"
GIT_EMAIL="mpriscella@gmail.com"

# Set by parse_args (--build-only): build the configuration without
# activating it.
BUILD_ONLY=false

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
# Parse command-line arguments.
# Arguments:
#   Script arguments ("$@")
# Globals:
#   BUILD_ONLY, CONFIG_ARG
#######################################
parse_args() {
  CONFIG_ARG=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --build-only)
      BUILD_ONLY=true
      ;;
    -*)
      log_error "Unknown option: $1"
      exit 1
      ;;
    *)
      CONFIG_ARG="$1"
      ;;
    esac
    shift
  done
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
    return
  fi

  # GitHub Codespaces clones this repo and runs install.sh unattended, so the
  # minimal profile has to be selected without an argument. The codespaces
  # configurations assume the `codespace` user from the GitHub-provided
  # images; pass a configuration explicitly on a devcontainer that runs as
  # someone else.
  local suffix=""
  case "$(uname -m)" in
  aarch64 | arm64)
    suffix="-arm"
    ;;
  esac

  if [[ -n "${CODESPACES:-}" ]]; then
    CONFIGURATION="codespaces$suffix"
    log_info "Codespaces detected; using the '$CONFIGURATION' configuration."
  else
    CONFIGURATION="linux$suffix"
  fi
}

#######################################
# Apply (or, with --build-only, just build) the flake configuration with
# nix-darwin or Home Manager.
# Globals:
#   OS, DOTFILES_DIR, CONFIGURATION, BUILD_ONLY
#######################################
apply_configuration() {
  cd "$DOTFILES_DIR"

  local action="switch"
  if [[ "$BUILD_ONLY" == true ]]; then
    action="build"
  fi

  # Upstream Nix doesn't enable flakes by default, and the nix.conf that does
  # (home-manager/home.nix) is deployed *by* this very switch — so the
  # bootstrap run has to supply the features itself.
  #
  # It takes both forms. A command-line --extra-experimental-features
  # configures only the `nix run` process; home-manager and darwin-rebuild
  # each shell out to their own `nix build`/`nix eval` children, and those
  # read nix.conf and NIX_CONFIG but never inherit the parent's flags. So the
  # flag covers `nix run` itself (reliable even where sudo is fussy about
  # environment assignments) and NIX_CONFIG covers everything it spawns.
  # `sudo` resets the environment, hence passing it as a sudo argument below
  # rather than exporting it.
  local nix_features=(--extra-experimental-features "nix-command flakes")
  local nix_config="extra-experimental-features = nix-command flakes"

  # Keep whatever the caller already put in NIX_CONFIG; `sudo` below would
  # otherwise drop it along with the rest of the environment. CI passes an
  # access-tokens line this way, because `nix run github:...` resolves the
  # flake ref through api.github.com and the anonymous limit there is 60/hr
  # per IP — which the shared macOS runners exhaust on their own.
  if [[ -n "${NIX_CONFIG:-}" ]]; then
    nix_config="$NIX_CONFIG"$'\n'"$nix_config"
  fi

  if [[ "$OS" == "macos" ]]; then
    # `sudo nix run` evaluates the flake as root, but the checkout is owned by
    # the invoking user; mark it safe so git/nix don't reject it as "dubious
    # ownership". Guarded so re-runs don't append duplicate entries.
    if ! sudo git config --global --get-all safe.directory 2>/dev/null | grep -qxF "$DOTFILES_DIR"; then
      sudo git config --global --add safe.directory "$DOTFILES_DIR"
    fi

    log_info "Running darwin-rebuild $action for configuration '$CONFIGURATION'..."
    sudo NIX_CONFIG="$nix_config" nix run "${nix_features[@]}" github:nix-darwin/nix-darwin#darwin-rebuild -- "$action" --flake ".#$CONFIGURATION"
  else
    log_info "Running home-manager $action for configuration '$CONFIGURATION'..."
    NIX_CONFIG="$nix_config" nix run "${nix_features[@]}" github:nix-community/home-manager -- "$action" --flake ".#$CONFIGURATION"
  fi

  if [[ "$BUILD_ONLY" == true ]]; then
    log_success "✓ Configuration '$CONFIGURATION' built (not activated)"
  else
    log_success "✓ Configuration '$CONFIGURATION' applied"
  fi
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

#######################################
# Make the configuration reachable from bash, then hand interactive shells to
# fish.
#
# The single-user Nix installer appends its profile hook to the first profile
# file that already exists — ~/.profile in the GitHub images — and only a
# *login* shell reads that. The VS Code terminal in a Codespace starts bash
# interactive-but-not-login, so ~/.nix-profile/bin never reaches PATH and
# nothing the profile installs (fish, nvim, rg, bat) is callable. ~/.bashrc is
# read by every interactive bash, so the hook goes there instead.
#
# fish is exec'd rather than made the login shell with chsh: no sudo needed,
# the image's own ~/.bashrc setup still runs first, and a generation that
# somehow lacks fish leaves a working bash instead of an unusable account.
# Globals:
#   OS, BASHRC_MARKER
#######################################
BASHRC_MARKER='# >>> mpriscella/dotfiles >>>'

configure_bash_handoff() {
  [[ "$OS" == "linux" ]] || return 0

  local bashrc="$HOME/.bashrc"
  if [[ ! -f "$bashrc" ]]; then
    log_info "No ~/.bashrc; skipping the fish hand-off."
    return 0
  fi

  if grep -qF "$BASHRC_MARKER" "$bashrc"; then
    log_info "Nix profile hook and fish hand-off already present in ~/.bashrc."
    return 0
  fi

  log_info "Adding the Nix profile hook and fish hand-off to ~/.bashrc..."
  cat >>"$bashrc" <<EOF

$BASHRC_MARKER
# Managed by install.sh. Delete this block for plain, unmodified bash.
if [ -e "\$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "\$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# nix.sh is what normally puts the profile on PATH, but it belongs to the
# single-user install; a daemon install patches /etc instead and leaves no
# such file. Add the directory outright so this block doesn't depend on which
# installer ran.
case ":\$PATH:" in
*":\$HOME/.nix-profile/bin:"*) ;;
*) PATH="\$HOME/.nix-profile/bin:\$PATH" ;;
esac
export PATH

# Interactive shells continue in fish. INSIDE_FISH is exported into fish's
# environment, so a bash started *from* fish stays bash.
case "\$-" in
*i*)
  if [ -z "\${INSIDE_FISH:-}" ] && command -v fish >/dev/null 2>&1; then
    INSIDE_FISH=1 exec fish
  fi
  ;;
esac
# <<< mpriscella/dotfiles <<<
EOF

  log_success "✓ Interactive bash will now continue in fish"
  log_info "Open a new terminal (or run 'exec bash') to pick it up."
}

main() {
  parse_args "$@"

  log_info "Starting dotfiles installation..."

  check_prerequisites
  detect_os

  install_nix

  # Upstream Nix doesn't enable flakes by default; `apply_configuration`
  # supplies the experimental features for the bootstrap run (see the note
  # there about why it takes both a flag and NIX_CONFIG).

  resolve_dotfiles_dir
  clone_dotfiles
  detect_configuration "$CONFIG_ARG"
  apply_configuration

  # Depends on the profile the switch just built, so it runs afterward.
  # Nothing was activated under --build-only, so there is no profile to point
  # bash at.
  if [[ "$BUILD_ONLY" != true ]]; then
    configure_bash_handoff
  fi

  # gpg/pinentry are provided by the configuration just applied, so this must
  # run afterward.
  # Skipped for --build-only (nothing was activated, so the configuration's
  # gpg isn't on any profile) and in Codespaces, where the profile disables
  # commit signing and the prompt would block an unattended install.
  if [[ "$BUILD_ONLY" != true && -z "${CODESPACES:-}" ]]; then
    ensure_gpg_key
  fi
}

main "$@"
