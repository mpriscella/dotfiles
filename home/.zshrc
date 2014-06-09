export ZSH=$HOME/.oh-my-zsh
export ENV='mpriscella'

ZSH_THEME="robbyrussell"
DISABLE_AUTO_TITLE=true
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git, brew, pip, vagrant)

source $ZSH/oh-my-zsh.sh

export PATH="/Users/mpriscella/.rvm/gems/ruby-2.1.1/bin:/Users/mpriscella/.rvm/gems/ruby-2.1.1@global/bin:/Users/mpriscella/.rvm/rubies/ruby-2.1.1/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/Users/mpriscella/.rvm/bin:/Users/mpriscella/.bin"
export EDITOR='vim'

# Aliases #
alias l='ls -1'
alias ll='ls -al'
alias ios='open /Applications/Xcode.app/Contents/Applications/iPhone\ Simulator.app'

