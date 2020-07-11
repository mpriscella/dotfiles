#!/bin/sh

if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$NAME
fi

case $OS in
  "Amazon Linux")
    yum install -y git tar util-linux-user vim zsh
    ;;
  "Alpine Linux")
    apk add bash curl git ncurses perl vim zsh
    ;;
  "Ubuntu")
  "Debian GNU/Linux")
    apt-get update
    apt-get install -y curl git locales tar vim zsh

    export LANGUAGE=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    locale-gen en_US.UTF-8
    ;;
  *)
    echo "Operating System $OS not found."
esac

ln -s $(pwd)/.ackrc ~/.ackrc
ln -s $(pwd)/.gitconfig ~/.gitconfig
ln -s $(pwd)/.tmux.conf ~/.tmux.conf
ln -s $(pwd)/.vimrc ~/.vimrc
ln -s $(pwd)/.zshrc ~/.zshrc

zsh -c "source ~/.zshrc; zplug install"
vim +PlugInstall +qall

chsh -s $(which zsh)
