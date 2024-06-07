-- https://wezfurlong.org/wezterm/config/files.html

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font 'SpaceMono Nerd Font'
config.color_scheme = 'GitHub Dark'

-- and finally, return the configuration to wezterm
return config
