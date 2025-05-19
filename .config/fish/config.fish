if status is-interactive
  # Commands to run in interactive sessions can go here

  # Set up Homebrew.
  set --global --export HOMEBREW_PREFIX "/opt/homebrew";
  set --global --export HOMEBREW_CELLAR "/opt/homebrew/Cellar";
  set --global --export HOMEBREW_REPOSITORY "/opt/homebrew";
  fish_add_path --global --move --path "/opt/homebrew/bin" "/opt/homebrew/sbin";
  if test -n "$MANPATH[1]"; set --global --export MANPATH '' $MANPATH; end;
  if not contains "/opt/homebrew/share/info" $INFOPATH; set --global --export INFOPATH "/opt/homebrew/share/info" $INFOPATH; end;

  if type -q atuin; then
    atuin init fish | source
  end
end

set pure_enable_k8s true
set pure_show_system_time true
set pure_enable_nixdevshell true

if type -q direnv; then
  # Load direnv hook for fish.
  # https://direnv.net/docs/hook.html.
  direnv hook fish | source
end
