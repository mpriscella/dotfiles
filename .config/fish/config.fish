if status is-interactive
  # Commands to run in interactive sessions can go here
  set PATH /opt/homebrew/bin:$PATH

  # Maybe check if atuin exists first.
  atuin init fish | source
end

set pure_enable_k8s true
set pure_show_system_time true
set pure_enable_nixdevshell true

set -x NIXPKGS_ALLOW_UNFREE 1
set -x TF_PLUGIN_CACHE_DIR "$HOME/.terraform.d/plugin-cache"

# Load direnv hook for fish.
# https://direnv.net/docs/hook.html.
direnv hook fish | source
