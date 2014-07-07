export ZSH=$HOME/.oh-my-zsh
export ENV='mpriscella'

# ZSH_THEME="mpriscella"
ZSH_THEME="robbyrussell"
DISABLE_AUTO_TITLE=true
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_AUTO_UPDATE="true"


plugins=(git, brew, pip, vagrant)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.rvm/gems/ruby-2.1.1/bin:$HOME/.rvm/gems/ruby-2.1.1@global/bin:$HOME/.rvm/rubies/ruby-2.1.1/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.rvm/bin:$HOME/.bin"
export EDITOR='vim'

# Aliases #
alias l='ls -1'
alias ll='ls -al'
alias ios='open /Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app'

# Tmux Aliases #
alias tn='tmux new -s'
alias tl='tmux list-sessions'
alias ta='tmux attach -t'
alias tk='tmux kill-session -t'

if [[ -a ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

