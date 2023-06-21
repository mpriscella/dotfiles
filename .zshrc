# zmodload zsh/zprof

######## zinit (https://github.com/zdharma-continuum/zinit) integration ########

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

##################################### brew #####################################

if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"

  if (( $+commands[brew] ))
  then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

#################################### Theme #####################################

zinit load mafredri/zsh-async
zinit load sindresorhus/pure

################################################################################

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# Use vi mode with ZSH Line Editor (zle).
# See https://zsh.sourceforge.io/Guide/zshguide04.html for documentation.
bindkey -v

# (F)astly Debug.
alias fdebug='curl -svo /dev/null -H "Fastly-Debug: true"'
# (H)eader C(url).
alias hurl='curl -sLD - -o /dev/null'
alias reload='source ~/.zshrc'
# (T)ime (T)o (F)irst (B)yte.
alias ttfb='curl -o /dev/null -H "Cache-Control: no-cache" -s -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n"'

# Enable colored output for default commands.
alias grep='grep --color=auto '

# Need to see if this works or if we need to use ls --color=auto
if ls -G > /dev/null 2>&1 ; then
  alias ls='ls -G'
else
  alias ls='ls --color=always'
fi

export PATH=$HOME/.bin:$PATH

##################################### aws ######################################

if (( $+commands[aws] && $+commands[aws_completer] ))
then
  aws_completer_path=$(which aws_completer)
  complete -C $aws_completer_path aws

  export AWS_CLI_AUTO_PROMPT=on-partial

  if [ -z "$AWS_PROFILE" ]; then
    export AWS_PROFILE=default
  fi

  #######################################
  # Switch between AWS Profiles.
  # Arguments:
  #   None
  #######################################
  function aws-ps {
    profile=$(aws configure list-profiles | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)
    if [ ! -z "$profile" ]; then
      export AWS_PROFILE=$profile
    fi
  }

  #######################################
  # Log into ECR repositories.
  # Arguments:
  #   None
  #######################################
  function ecr-login {
    region=$(aws configure get region)
    name=$(aws ecr describe-repositories --output json --query "repositories[*].repositoryName" | jq -r '.[]' | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)
    uri=$(aws ecr describe-repositories --repository-names "$name" --output json --query "repositories[*].repositoryUri" | jq -r '.[]')

    echo "Logging into $uri..."
    aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$uri"
  }
fi

#################################### Editor ####################################

if (( $+commands[nvim] ))
then
  export GIT_EDITOR=nvim
  export KUBE_EDITOR=nvim

  alias vi=nvim
  alias vim=nvim
else
  export GIT_EDITOR=vim
  export KUBE_EDITOR=vim

  alias vi=vim
fi

############## FZF (https://github.com/junegunn/fzf) integration ###############

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey -s '^P' 'fzf^M'
export FZF_DEFAULT_COMMAND='find . -not -path "**/.git/**"'

################################## Kubernetes ##################################

if (( $+commands[helm] ))
then
  source <(helm completion zsh)
fi

if (( $+commands[kind] ))
then
  source <(kind completion zsh)
fi

export RPROMPT=""
if (( $+commands[kubectl] ))
then
  source <(kubectl completion zsh)
  zinit load jonmosco/kube-ps1

  export KUBE_PS1_DIVIDER="/"
  export KUBE_PS1_SYMBOL_ENABLE=false
fi

#################################### GitHub ####################################

if (( $+commands[gh] ))
then
  source <(gh completion --shell zsh)
fi

################################### Functions ##################################

if (( $+commands[helm] && $+commands[kubectl] )) {
  [ -f ~/.kshell.sh ] && source ~/.kshell.sh
}

############################### Load Local zshrc ###############################

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

if (( $+commands[kubectl] ))
then
  export RPROMPT='%{$fg[green]%}${AWS_PROFILE}%{$reset_color%}%::$(kube_ps1)'
fi

# zprof
