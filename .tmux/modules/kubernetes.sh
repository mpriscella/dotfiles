#!/bin/bash

show_kubernetes() {
  local index icon color text module

  # context=$(kubectl config view --minify -o jsonpath='{.current-context}')
  # namespace=$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}')

  index=$1
  icon=$(get_tmux_option "@catppuccin_kubernetes_icon" "󱃾")
  color=$(get_tmux_option "@catppuccin_kubernetes_color" "$thm_blue")
  text=$(get_tmux_option "@catppuccin_kubernetes_text" "#( $HOME/.tmux/modules/get_kubernetes_context.sh )")

  module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo "$module"
}
