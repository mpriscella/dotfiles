#!/bin/bash

source functions.sh

ENABLE_TMUX=FALSE

#######################################
# Install package dependencies.
# Globals:
#   ADJUSTED_ID
#   ENABLE_TMUX
# Arguments:
#   None
#######################################
install_dependencies() {
  # Install atuin.
  curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/download/v18.4.0/atuin-installer.sh | sh

  # Install nvm.
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 

  nvm install node
  npm install -g  @devcontainers/cli

  if [ "${ADJUSTED_ID}" = "debian" ]; then
    check_packages ack build-essential ca-certificates curl fd-find fzf gawk \
      git jq locales ripgrep tar vim virt-what zsh

    # Set locale.
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    echo 'LANG=en_US.UTF-8' > /etc/default/locale
    locale-gen

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
    check_packages ack act derailed/k9s/k9s direnv fish fd fzf gh gnupg \
      helm jordanbaird-ice jq kind jesseduffield/lazygit/lazygit neovim \
      orbstack ripgrep yq yt-dlp

    nvm install node

    # Hopefully can move the following into nix:
    #   - dive
    #   - k6
    #   - shellcheck
    #   - sslscan (?)
    #   - step
    #   - terraform-ls
    #   - tree-sitter

    # Change shell to fishshell.
    if ! grep -q '/fish$' /etc/shells; then
      which fish | sudo tee -a /etc/shells
      chsh -s "$(which fish)"
    fi
  fi

  if [ "${ENABLE_TMUX}" = "TRUE" ]; then
    install_tmux
  fi

  # Install fisher.
  fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

  # Install pure.
  fish -c "fisher install pure-fish/pure"

  clean_up
}

#######################################
# Symlinks the dotfiles to their correct destination in the home directory.
# Globals:
#   files
#   HOME
# Arguments:
#   None
#######################################
install_dotfiles() {
  files=".ackrc .config/ghostty .config/nvim .dotfiles.gitconfig .gitattributes .zshrc"

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

#######################################
# Installs Homebrew.
# Globals:
#   TMPDIR
# Arguments:
#   None
#######################################
install_homebrew() {
  if ! type brew >/dev/null 2>&1; then
    VERSION=$(curl -s https://api.github.com/repos/Homebrew/brew/releases/latest | grep '"tag_name":' | sed -E 's/.*"tag_name": "v?([^"]*).*/\1/')
    CURL -Lo "${TMPDIR}"/brew.pkg "https://github.com/Homebrew/brew/releases/download/${VERSION}/Homebrew-${VERSION}.pkg"
    sudo installer -pkg "${TMPDIR}"/brew.pkg -target /
    rm "${TMPDIR}"/brew.pkg

    # Create $HOME/.zprofile if it doesn't exist.
    if [ -f "$HOME"/.zprofile ]; then
      echo >> "$HOME"/.zprofile
    fi

    # shellcheck disable=SC2016
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME"/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  PATH="/opt/homebrew/bin:$PATH"
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
  # TODO: Check if neovim is installed already.
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

if [ "${ADJUSTED_ID}" = "darwin" ]; then
  install_homebrew
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

case "$1" in
"install")
  install_dependencies
  echo "✅ Dependencies installed."

  install_dotfiles
  echo "✅ Dotfiles installed."
  echo "Opening fish shell..."

  # Open a fish shell and, when the shell exits, kill the shell that the
  # script executed in.
  fish && kill -9 $PPID
  # TODO: Maybe there's a way to restart the current application?
  # Maybe an automator script
  ;;
*)
  usage
  ;;
esac

# TODO: How to run this automatically?
# nix profile install nixpkgs#nix-direnv
# echo "source $HOME/.nix-profile/share/nix-direnv/direnvrc" >> "$HOME"/.config/direnv/direnvrc
