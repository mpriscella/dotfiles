#!/bin/bash

function usage() {
  echo "Manages mpriscella/dotfiles."
  echo ""
  echo "Usage:"
  echo "  ./dotfiles.sh [command]"
  echo ""
  echo "Available Commands:"
  echo "  clean    Cleans any backup files generated from the install command."
  echo "  install  Installs dotfiles and predefined packages."
  echo ""
}

files=".ackrc .config/nvim/init.lua .dotfiles.gitconfig .gitattributes .kshell.sh .tmux.conf .vimrc .zshrc"

function config_tmux() {
  if [ ! -d "$HOME"/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins/tpm && "$HOME"/.tmux/plugins/tpm/bin/install_plugins
  fi
  "$HOME"/.tmux/plugins/tpm/bin/install_plugins
}

function install_dotfiles() {
  # shellcheck source=src/functions.sh
  source src/functions.sh

  case $(uname -s) in
  "Linux")
    if command -v apt >/dev/null 2>&1; then
      packages=(
        ack
        curl
        exuberant-ctags
        gawk
        git
        jq
        locales
        python3
        tar
        tmux
        vim
        virt-what
        zsh
      )
      PACKAGE_MANAGER="apt" install_packages "${packages[@]}"
    fi

    if command -v yum >/dev/null 2>&1; then
      packages=(
        git
        jq
        tar
        util-linux-user
        vim
        virt-what
        zsh
      )

      if [ "$(sed -n -e 's/PRETTY_NAME=//p' /etc/os-release)" == "\"Amazon Linux 2023\"" ]; then
        packages+=(
          cmake
          make
          gcc
          gettext
          gzip
        )
      fi

      PACKAGE_MANAGER="yum" install_packages "${packages[@]}"
    fi

    install_neovim
    install_zunit
    ;;
  "Darwin")
    if ! command -v brew >/dev/null 2>&1; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew tap homebrew/cask-fonts
    brew install --casks \
      dbeaver-community \
      font-space-mono-nerd-font
    brew install derailed/k9s/k9s dive gh helm jq shellcheck sslscan step tmux yq yt-dlp
    ;;
  *)
    echo "Operating System '$OS' not supported."
    ;;
  esac

  for i in $files; do
    mkdir --parents "$(dirname "$HOME"/"$i")"
    if [ "$(readlink "$HOME"/"$i")" != "$PWD"/"$i" ]; then
      rm "$HOME"/"$i"
    elif [ ! -L "$HOME"/"$i" ] && [ -f "$HOME"/"$i" ]; then
      mv "$HOME"/"$i" "$HOME"/"$i".bkup
    fi

    ln -s "$PWD"/"$i" "$HOME"/"$i"
  done

  nvim --headless "+Lazy! install" +qa

  git config --global include.path "$HOME"/.dotfiles.gitconfig
  config_tmux
}

case "$1" in
"install")
  install_dotfiles
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
