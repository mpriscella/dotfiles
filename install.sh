#!/bin/sh

# Alpine based image.
if command -v apk &> /dev/null
then
  apk add curl git ncurses perl vim zsh
# Fedora based image.
elif command -v yum &> /dev/null
then
  yum install -y git vim zsh
# Debian based image.
elif command -v apt-get &> /dev/null
then
  apt-get update
  apt-get install -y git locales vim zsh

  export LANGUAGE=en_US.UTF-8
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  locale-gen en_US.UTF-8
  # dpkg-reconfigure locales
fi

ln -s $(pwd)/.ackrc ~/.ackrc
ln -s $(pwd)/.gitconfig ~/.gitconfig
ln -s $(pwd)/.tmux.conf ~/.tmux.conf
ln -s $(pwd)/.vimrc ~/.vimrc
ln -s $(pwd)/.zshrc ~/.zshrc

zsh -c "source ~/.zshrc; zplug install"
vim +PlugInstall +qall

zsh
