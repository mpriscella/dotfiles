#!/bin/bash

show_aws_profile() {
  local index icon color text module

  index=$1
  icon=$(get_tmux_option "@catppuccin_aws_profile_icon" "󰸏")
  color=$(get_tmux_option "@catppuccin_aws_profile_color" "$thm_orange")
  text=$(get_tmux_option "@catppuccin_aws_profile_text" "#( $HOME/.tmux/modules/get_aws_profile.sh )")

  module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo "$module"
}
