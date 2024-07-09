#!/bin/bash

show_time() {
  local index icon color text module

  index=$1
  icon="$(get_tmux_option "@catppuccin_time_icon" "")"
  color="$(get_tmux_option "@catppuccin_time_color" "${thm_yellow:?}")"
  text="$(get_tmux_option "@catppuccin_time_text" "%H:%M")"

  module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo "$module"
}
