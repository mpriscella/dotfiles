if test -f ~/.config/fish/aliases.fish
  source ~/.config/fish/aliases.fish
end

if test -f ~/.config/fish/local.fish
  source ~/.config/fish/local.fish
end

function reload
  source ~/.config/fish/config.fish
end

function notify
  if hash terminal-notifier 2>/dev/null
    terminal-notifier -title "Terminal" -message "$1" -activate "com.googlecode.iterm2" -sound "Glass"
  else
    echo "'notify' requires terminal-notifier. Please run"
    echo "    brew install terminal-notifier"
    echo "to install"
  end
end

if test -n "$TMUX"
  set -x TERM xterm-256color
end

function fish_prompt --description 'Write out the prompt'
   if not set -q __fish_prompt_normal
     set -g __fish_prompt_normal (set_color normal)
   end

   if not set -q __fish_prompt_cwd
     set -g __fish_prompt_cwd (set_color $fish_color_cwd)
   end

   echo -n -s "$__fish_prompt_cwd" (prompt_pwd) (set_color blue) (__fish_git_prompt) (set_color normal) "$__fish_prompt_normal" ' > '
end

function fish_greeting
  echo (gshuf -n 1 ~/.config/fish/gus_dont_be_lines)
end
