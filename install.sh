#!bin/bash

# If ~/.config/fish doesn't exist, create it.
ln -sF $PWD/fish/config.fish ~/.config/fish/config.fish
ln -sF $PWD/fish/aliases.fish ~/.config/fish/aliases.fish
ln -sF $PWD/fish/gus_dont_be_lines ~/.config/fish/gus_dont_be_lines

ln -sF $PWD/ackrc ~/.ackrc
ln -sF $PWD/vimrc ~/.vimrc
ln -sF $PWD/nvimrc ~/.nvimrc
ln -sF $PWD/tmux.conf ~/.tmux.conf
ln -sF $PWD/gitconfig ~/.gitconfig
ln -sF $PWD/bin ~/.bin
