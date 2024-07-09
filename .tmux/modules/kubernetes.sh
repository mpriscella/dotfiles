#!/bin/bash

show_kubernetes() {
  local index icon color text module

  index=$1
  icon=$(get_tmux_option "@catppuccin_kubernetes_icon" "󱃾")
  color=$(get_tmux_option "@catppuccin_kubernetes_color" "${thm_blue:?}")
  text=$(get_tmux_option "@catppuccin_kubernetes_text" "#( $HOME/.tmux/modules/get_kubernetes_context.sh )")

  module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo "$module"
}
