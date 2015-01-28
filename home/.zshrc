#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

if [[ -a ~/.zaliases ]]; then
  source ~/.zaliases
fi

if [[ -a ~/.zaliases.local ]]; then
  source ~/.zaliases.local
fi

if [[ -a ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

alias tn="tmux new -s"
alias ta="tmux attach -t"
alias tl="tmux list-sessions"
alias tk="tmux kill-session -t"
