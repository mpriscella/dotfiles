#!/bin/sh

case $(uname -s) in
  "Linux")
    if command -v apt > /dev/null 2>&1; then
      apt-get update -y
      apt-get install -y curl exuberant-ctags gawk git jq locales python tar vim zsh

      export LANG=en_US.UTF-8
      echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
      locale-gen
    fi

    if command -v yum > /dev/null 2>&1; then
      yum update
      yum install -y git jq tar util-linux-user vim zsh
    fi

    if command -v apk > /dev/null 2>&1; then
      apk add bash curl git jq ncurses perl vim zsh
    fi
    ;;
  "Darwin")
    ;;
  *)
    echo "Operating System $OS not found."
esac

files=".ackrc .docker.aliases.zshrc .gitconfig .tmux.conf .vimrc .zshrc"

for i in $files; do
  if test -f ~/"$i"; then
    mv ~/"$i" ~/"$i".bkup
  fi
  ln -s "$(pwd)/$i" ~/"$i"
done

zsh -c "source ~/.zshrc; zplug install"
vim +PlugInstall +qall
