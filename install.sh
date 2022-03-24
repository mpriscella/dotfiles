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
    ;;
  *)
    echo "Operating System '$OS' not supported."
esac

files=".ackrc .gitconfig .tmux.conf .vimrc .zshrc"

for i in $files; do
  if [ "$(readlink "$HOME"/"$i")" != "$PWD"/"$i" ]; then
    rm "$HOME"/"$i"
  elif test -f "$HOME"/"$i"; then
    mv "$HOME"/"$i" "$HOME"/"$i".bkup
  fi

  ln -s "$PWD"/"$i" "$HOME"/"$i"
done

vim +PlugInstall +qall
