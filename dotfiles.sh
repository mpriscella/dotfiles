#!/bin/bash

# User defined configs.
ENABLE_TMUX=FALSE

SUDO=""
if type sudo >/dev/null 2>&1; then
  SUDO="sudo "
fi

#######################################
# Print script usage.
# Globals:
#   None
# Arguments:
#   None
#######################################
usage() {
  echo "Manages mpriscella/dotfiles."
  echo ""
  echo "Usage:"
  echo "  ./dotfiles.sh [command]"
  echo ""
  echo "Available Commands:"
  echo "  clean    Removes any backup files generated from the install command."
  echo "  install  Installs dotfiles and predefined packages."
  echo ""
}

# Bring in ID and ID_LIKE, if the file exists.
if [ -f /etc/os-release ]; then
  # shellcheck source=/dev/null
  source /etc/os-release
fi

# Normalize the OS ID.
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
  ADJUSTED_ID="debian"
elif [ "$(uname -s)" = "Darwin" ]; then
  ADJUSTED_ID="darwin"
fi

ARCHITECTURE="$(uname -m)"

# Install Homebrew on MacOS.
if [ "${ADJUSTED_ID}" = "darwin" ]; then
  if ! type brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Create $HOME/.zprofile if it doesn't exist.
    if [ -f "$HOME"/.zprofile ]; then
      echo >> "$HOME"/.zprofile
    fi

    # shellcheck disable=SC2016
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME"/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Determine what the package manager install command for the OS is.
if type apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  INSTALL_CMD=apt-get
elif type brew >/dev/null 2>&1; then
  INSTALL_CMD=brew
else
  echo "(Error) Unable to find a supported package manager."
  exit 1
fi

#######################################
# Update package manager.
# Globals:
#   INSTALL_CMD
#   SUDO
# Arguments:
#   None
#######################################
pkg_mgr_update() {
  if [ "${INSTALL_CMD}" = "apt-get" ]; then
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
      echo "Running apt-get update..."
      "${SUDO}""${INSTALL_CMD}" update -y
    fi
  elif [ "${INSTALL_CMD}" = "brew" ]; then
    echo "Running brew update ..."
    "${INSTALL_CMD}" update
  fi
}

#######################################
# Ensure packages are installed.
# Globals:
#   ID
#   INSTALL_CMD
#   SUDO
# Arguments:
#   List of packages to install.
#######################################
check_packages() {
  # TODO: Check if package is installed and if so, skip it.
  # Also, we shouldn't update for each package since that will take forever.
  if [ "${INSTALL_CMD}" = "apt-get" ]; then
    if ! dpkg -s "$@" >/dev/null 2>&1; then
      pkg_mgr_update
      "${SUDO}""${INSTALL_CMD}" -y install --no-install-recommends "$@"
    fi
  elif [ "${INSTALL_CMD}" = "brew" ]; then
    pkg_mgr_update
    "${INSTALL_CMD}" install "$@"
  else
    echo "Linux distro ${ID} not supported."
    exit 1
  fi
}

#######################################
# Clean up package manager cache files.
# Globals:
#   ADJUSTED_ID
# Arguments:
#   None
#######################################
clean_up() {
  case "${ADJUSTED_ID}" in
  debian)
    rm -rf /var/lib/apt/lists/*
    ;;
  darwin)
    brew cleanup
    ;;
  esac
}

#######################################
# Install package dependencies.
# Globals:
#   ADJUSTED_ID
#   ENABLE_TMUX
# Arguments:
#   None
#######################################
install_dependencies() {
  if [ "${ADJUSTED_ID}" = "debian" ]; then
    check_packages ack build-essential ca-certificates curl exuberant-ctags \
      fd-find fzf gawk git jq locales python3 ripgrep tar vim virt-what zsh

    # Do I need?
    #   - exuberant-ctags
    #   - python3

    # Set locale.
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    echo 'LANG=en_US.UTF-8' > /etc/default/locale
    locale-gen

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    nvm install 22
    npm install -g tree-sitter-cli @devcontainers/cli
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    install_neovim

    # TODO: Install:
    #   - fish
    #   - lazygit

  elif [ "${ADJUSTED_ID}" = "darwin" ]; then
    brew install --casks dbeaver-community devtoys
    # TODO: This list of packages should be a variable. Then we loop over it,
    # check to see if it's installed, and if not, install it. This might be
    # applicable to debian as well, perhaps we can create a function to check if
    # a package is installed that's package manager agnostic.
    check_packages ack act atuin derailed/k9s/k9s direnv dive fish fd fzf gh \
      gnupg helm jordanbaird-ice jq k6 kind jesseduffield/lazygit/lazygit \
      neovim nvm ripgrep shellcheck sslscan step terraform-ls tree-sitter yq \
      yt-dlp
    # Hopefully can move the following into nix:
    #   - dive
    #   - gnupg (?)
    #   - k6
    #   - shellcheck
    #   - sslscan (?)
    #   - step
    #   - terraform-ls
    #   - tree-sitter

    npm install -g @devcontainers/cli

    # TODO: Check /etc/shells to see if fish is already in there.
    # Change shell to fishshell.
    which fish | sudo tee -a /etc/shells
    chsh -s "$(which fish)"
  fi

  # TODO: Maybe move changing of shell out of platform specfic conditional.

  if [ "${ENABLE_TMUX}" = "TRUE" ]; then
    install_tmux
  fi

  clean_up
}

#######################################
# Installs neovim.
# Globals:
#   ARCHITECTURE
#   HOME
#   PATH
# Arguments:
#   None
#######################################
install_neovim() {
  NEOVIM_VERSION=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  if ARCHITECTURE="aarch64"; then
    NEOVIM_ARCHITECTURE="arm64"
  else
    NEOVIM_ARCHITECTURE="$ARCHITECTURE"
  fi
  curl -Lo "${HOME}"/neovim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${NEOVIM_ARCHITECTURE}.tar.gz"
  mkdir -p "${HOME}"/neovim
  tar xf "${HOME}"/neovim.tar.gz -C "${HOME}"/neovim --strip-components=1
  export PATH="${HOME}"/neovim/bin:"${PATH}"
  rm "${HOME}"/neovim.tar.gz
}

#######################################
# Installs and configures tmux.
# Globals:
#   HOME
# Arguments:
#   None
#######################################
install_tmux() {
  check_packages tmux

  # NOTE: I can keep tmux, but I'm going to try and not use it as much. It
  # shouldn't be installed by default. Same goes for it's config. Maybe we can
  # have an env var that defaults to false and determines whether to install /
  # configure tmux.
  if [ ! -d "$HOME"/.tmux/plugins/tpm ]; then
    TPM_VERSION=v3.1.0
    git clone --depth 1 --branch "${TPM_VERSION}" https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins/tpm
  fi
  "$HOME"/.tmux/plugins/tpm/bin/install_plugins
}

files=".ackrc .config/ghostty .config/nvim .dotfiles.gitconfig .gitattributes .zshrc"

#######################################
# Symlinks the dotfiles to their correct destination in the home directory.
# Globals:
#   files
#   HOME
# Arguments:
#   None
#######################################
install_dotfiles() {
  for i in $files; do
    #   If it doesn't exist, create it
    #   loop over files in dotfiles directory and symlink them to directory on host.

    # If the file is a directory
    if [ -d "$i" ]; then
      # Loop over files in the directory
      # Probably needs to be recursive.
      for j in "$i"/*; do
        mkdir -p "$HOME"/"$i"
        ln -s "$PWD"/"$j" "$HOME"/"$i"
      done
    fi

    mkdir -p "$(dirname "$HOME"/"$i")"
    if [ "$(readlink "$HOME"/"$i")" != "$PWD"/"$i" ]; then
      rm "$HOME"/"$i"
    elif [ ! -L "$HOME"/"$i" ] && [ -f "$HOME"/"$i" ]; then
      mv "$HOME"/"$i" "$HOME"/"$i".bkup
    fi

    ln -s "$PWD"/"$i" "$HOME"/"$i"
  done

  # TODO: Maybe put this in a function later.
  # Probaly unnecessary since this is the only configuration needed for git.
  git config --global include.path "$HOME"/.dotfiles.gitconfig
}

case "$1" in
"install")
  install_dependencies
  echo "✅ Dependencies installed."

  install_dotfiles
  echo "✅ Dotfiles installed."
  ;;
*)
  usage
  ;;
esac
