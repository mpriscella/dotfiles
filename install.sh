#!/bin/bash

# shellcheck source=src/functions.sh
source src/functions.sh

case $(uname -s) in
  "Linux")
    if command -v apt > /dev/null 2>&1; then
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

    if command -v yum > /dev/null 2>&1; then
      packages=(
        git
        jq
        tar
        util-linux-user
        vim
        zsh
        virt-what
      )
      PACKAGE_MANAGER="yum" install_packages "${packages[@]}"
    fi

    # if command -v apk > /dev/null 2>&1; then
    #   apk add bash curl git jq ncurses perl vim zsh virt-what
    # fi
    ;;
  "Darwin")
    if ! command -v brew > /dev/null 2>&1; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if ! command -v git-credential-manager-core > /dev/null 2>&1; then
      brew install tmux shellcheck dive gh helm yq linkerd step jq
      brew install --cask 1password/tap/1password-cli
    fi
    ;;
  *)
    echo "Operating System '$OS' not supported."
esac

files=".ackrc .tmux.conf .vimrc .zshrc"

for i in $files; do
  if [ "$(readlink "$HOME"/"$i")" != "$PWD"/"$i" ]; then
    rm "$HOME"/"$i"
  elif test -f "$HOME"/"$i"; then
    mv "$HOME"/"$i" "$HOME"/"$i".bkup
  fi

  ln -s "$PWD"/"$i" "$HOME"/"$i"
done

vim +PlugInstall +qall
