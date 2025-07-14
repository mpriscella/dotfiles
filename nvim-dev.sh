#!/bin/bash

# Set up isolated Neovim environment
CONFIG_DIR="$(pwd)/.config/nvim"
DATA_DIR="$(pwd)/nvim-data"
CACHE_DIR="$(pwd)/nvim-cache"

# Create directories if they don't exist
mkdir -p "$DATA_DIR" "$CACHE_DIR"

# Add the config directory to Lua package path
XDG_CONFIG_HOME="$CONFIG_DIR" \
  XDG_DATA_HOME="$DATA_DIR" \
  XDG_CACHE_HOME="$CACHE_DIR" \
  nvim -u "$CONFIG_DIR/init.lua" \
  --cmd "set runtimepath^=$CONFIG_DIR" \
  --cmd "lua package.path = '$CONFIG_DIR/lua/?.lua;$CONFIG_DIR/lua/?/init.lua;' .. package.path" \
  "$@"
