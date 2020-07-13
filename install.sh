#!/bin/sh

if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$NAME
else
  OS=$(uname -s)
fi

case $OS in
  "Amazon Linux")
    yum install -y git tar util-linux-user vim zsh
    ;;
  "Alpine Linux")
    apk add bash curl git ncurses perl vim zsh
    ;;
  "Debian GNU/Linux")
    apt-get update
    apt-get install -y curl gawk git locales python tar vim zsh

    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    ;;
  "Ubuntu")
    apt-get update
    apt-get install -y curl gawk git locales python tar vim zsh

    export LANG=en_US.UTF-8
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    ;;
  *)
    echo "Operating System $OS not found."
esac

ln -s $(pwd)/.ackrc ~/.ackrc
ln -s $(pwd)/.docker.aliases.zshrc ~/.docker.aliases.zshrc
ln -s $(pwd)/.gitconfig ~/.gitconfig
ln -s $(pwd)/.tmux.conf ~/.tmux.conf
ln -s $(pwd)/.vimrc ~/.vimrc
ln -s $(pwd)/.zshrc ~/.zshrc

zsh -c "source ~/.zshrc; zplug install"
vim +PlugInstall +qall

chsh -s $(which zsh)
