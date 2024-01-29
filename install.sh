#!/bin/bash

if [ -z "$DEBUG_DOTFILES" ]; then
  ./dotfiles.sh install
fi
