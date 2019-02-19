if test -f ~/.config/fish/aliases.fish
  . ~/.config/fish/aliases.fish
end

if test -f ~/.config/fish/local.fish
  . ~/.config/fish/local.fish
end

if test -n "$TMUX"
  set -x TERM xterm-256color
end

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

function reload
  . ~/.config/fish/config.fish
end

function fish_prompt
   if not set -q __fish_prompt_normal
     set -g __fish_prompt_normal (set_color normal)
   end

   if not set -q __fish_prompt_cwd
     set -g __fish_prompt_cwd (set_color $fish_color_cwd)
   end

   echo -n -s "$__fish_prompt_cwd" (prompt_pwd) (set_color blue) (__fish_git_prompt) "$__fish_prompt_normal" ' $ '
end

function fish_greeting
  echo (gshuf -n 1 ~/.config/fish/gus_dont_be_lines)
end
