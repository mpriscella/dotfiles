#!/bin/bash

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

if [ -f /etc/os-release ]; then
  # shellcheck source=/dev/null
  source /etc/os-release
fi

if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
  ADJUSTED_ID="debian"
elif [ "$(uname -s)" = "Darwin" ]; then
  ADJUSTED_ID="darwin"
fi

if [ "${ADJUSTED_ID}" = "darwin" ]; then
  # Install homebrew.
  if ! type brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

if type apt-get >/dev/null 2>&1; then
  INSTALL_CMD=apt-get
elif type brew >/dev/null 2>&1; then
  INSTALL_CMD=brew
else
  echo "(Error) Unable to find a supported package manager."
  exit 1
fi

pkg_mgr_update() {
  if [ "${INSTALL_CMD}" = "apt-get" ]; then
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
      echo "Running apt-get update..."
      sudo "${INSTALL_CMD}" update -y
    fi
  elif [ "${INSTALL_CMD}" = "brew" ]; then
    echo "Running brew update ..."
    "${INSTALL_CMD}" update
  fi
}

# Checks if packages are installed and installs them if not
check_packages() {
  if [ "${INSTALL_CMD}" = "apt-get" ]; then
    if ! dpkg -s "$@" >/dev/null 2>&1; then
      pkg_mgr_update
      sudo "${INSTALL_CMD}" -y install --no-install-recommends "$@"
    fi
  elif [ "${INSTALL_CMD}" = "brew" ]; then
    pkg_mgr_update
    "${INSTALL_CMD}" install "$@"
  else
    echo "Linux distro ${ID} not supported."
    exit 1
  fi
}

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

install_dependencies() {
  if [ "${ADJUSTED_ID}" = "debian" ]; then
    check_packages ack curl exuberant-ctags gawk git jq locales python3 tar tmux vim virt-what zsh
    install_neovim >/dev/null 2>&1
  elif [ "${ADJUSTED_ID}" = "darwin" ]; then
    brew tap homebrew/cask-fonts
    brew install --casks dbeaver-community font-space-mono-nerd-font
    check_packages derailed/k9s/k9s dive gh helm jq kind neovim shellcheck sslscan step tmux yq yt-dlp
  fi

  clean_up
}

install_neovim() {
  old_dir="$PWD"
  cd "$HOME" || exit
  git clone --depth 1 --branch stable https://github.com/neovim/neovim.git
  cd neovim || exit
  check_packages ninja-build gettext cmake unzip
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  cd "$old_dir" || exit
}

spinner_pid=

function start_spinner {
  set +m
  echo -n "$1    "
  { while :; do for X in ".  " ".. " "..." " .." "  ." "   "; do
    echo -en "\b\b\b$X"
    sleep 0.1
  done; done & } 2>/dev/null
  spinner_pid=$!
}

function stop_spinner {
  { kill -9 "$spinner_pid" && wait; } 2>/dev/null
  set -m
  echo -en "\033[2K\r"
}

trap stop_spinner EXIT

######

files=".ackrc .config/nvim/init.lua .dotfiles.gitconfig .gitattributes .kshell.sh .tmux.conf .vimrc .zshrc"

config_tmux() {
  if [ ! -d "$HOME"/.tmux/plugins/tpm ]; then
    TPM_VERSION=v3.1.0
    git clone --depth 1 --branch "${TPM_VERSION}" https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins/tpm
  fi
  "$HOME"/.tmux/plugins/tpm/bin/install_plugins
}

install_dotfiles() {
  for i in $files; do
    mkdir -p "$(dirname "$HOME"/"$i")"
    if [ "$(readlink "$HOME"/"$i")" != "$PWD"/"$i" ]; then
      rm "$HOME"/"$i"
    elif [ ! -L "$HOME"/"$i" ] && [ -f "$HOME"/"$i" ]; then
      mv "$HOME"/"$i" "$HOME"/"$i".bkup
    fi

    ln -s "$PWD"/"$i" "$HOME"/"$i"
  done

  if type nvim >/dev/null 2>&1; then
    nvim --headless "+Lazy! install" +qa
  fi

  if type tmux >/dev/null 2>&1; then
    config_tmux
  fi

  git config --global include.path "$HOME"/.dotfiles.gitconfig
}

case "$1" in
"install")
  start_spinner "Installing dependencies"
  install_dependencies >/dev/null 2>&1
  stop_spinner
  echo "✅ Dependencies installed."

  start_spinner "Installing dotfiles"
  install_dotfiles >/dev/null 2>&1
  stop_spinner
  echo "✅ Dotfiles installed."
  ;;
"clean")
  for i in $files; do
    if test -f "$HOME"/"$i".bkup; then
      rm "$HOME"/"$i".bkup
    fi
  done
  ;;
*)
  usage
  ;;
esac
