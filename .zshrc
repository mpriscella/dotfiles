######## zinit (https://github.com/zdharma-continuum/zinit) integration ########

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname "$ZINIT_HOME")"
[ ! -d "$ZINIT_HOME"/.git ] && git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

##################################### brew #####################################

if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"

  if type "brew" >/dev/null; then
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

# (F)astly (Debug).
# Sends the Fastly-Debug header to an endpoint.
# Additional documentation: https://developer.fastly.com/reference/http/http-headers/Fastly-Debug/
alias fdebug='curl -svo /dev/null -H "Fastly-Debug: true"'
# (H)eader C(url).
alias hurl='curl -sLD - -o /dev/null'
# (T)ime (T)o (F)irst (B)yte.
alias ttfb='curl -o /dev/null -H "Cache-Control: no-cache" -s -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n"'

alias reload='source ~/.zshrc'

# Enable colored output for default commands.
# TODO should work on both darwin(mac) and linux.
alias grep='grep --color=auto '

# Need to see if this works or if we need to use ls --color=auto
# TODO should work on both darwin(mac) and linux.
if ls -G >/dev/null 2>&1; then
  alias ls='ls -G'
else
  alias ls='ls --color=always'
fi

export PATH=$HOME/.bin:$HOME/.nvim/bin:$PATH

##################################### aws ######################################

if (type "aws" >/dev/null && type aws_completer >/dev/null); then
  aws_completer_path=$(which aws_completer)
  complete -C "$aws_completer_path" aws

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
    if [ -n "$profile" ]; then
      export AWS_PROFILE=$profile
    fi
  }

  #######################################
  # Log into ECR repositories.
  # Arguments:
  #   None
  #######################################
  function ecr-login {
    if [[ $(aws sts get-caller-identity >/dev/null 2>&1) -ne 0 ]]; then
      echo "Could not connect to AWS account. Please verify that your credentials are correct."
      kill -INT $$
    fi

    region=$(aws configure get region)
    name=$(aws ecr describe-repositories --output json --query "repositories[*].repositoryName" | jq -r '.[]' | fzf --height=30% --layout=reverse --border --margin=1 --padding=1)
    uri=$(aws ecr describe-repositories --repository-names "$name" --output json --query "repositories[*].repositoryUri" | jq -r '.[]')

    echo "Logging into $uri..."
    aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$uri"
  }
fi

#################################### Editor ####################################

if type "nvim" >/dev/null; then
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

[ -f "$HOME"/.fzf.zsh ] && source "$HOME"/.fzf.zsh
bindkey -s '^P' 'fzf^M'
export FZF_DEFAULT_COMMAND='find . -not -path "**/.git/**"'

################################## Kubernetes ##################################

if type "helm" >/dev/null; then
  source <(helm completion zsh)
fi

if type "kind" >/dev/null; then
  source <(kind completion zsh)
fi

export RPROMPT=""
if type "kubectl" >/dev/null; then
  source <(kubectl completion zsh)
  zinit load jonmosco/kube-ps1

  export KUBE_PS1_DIVIDER="/"
  export KUBE_PS1_SYMBOL_ENABLE=false
fi

#################################### GitHub ####################################

if type "gh" >/dev/null; then
  source <(gh completion --shell zsh)
fi

################################### Functions ##################################

if (type "helm" >/dev/null && type "kubectl" >/dev/null); then
  [ -f "$HOME"/.kshell.sh ] && source "$HOME"/.kshell.sh
fi

############################### Load Local zshrc ###############################

# shellcheck source=/dev/null
[ -f "$HOME"/.zshrc.local ] && source "$HOME"/.zshrc.local

gen_prompt=''
if [ -n "$AWS_PROFILE" ]; then
  gen_prompt='%{$fg[green]%}${AWS_PROFILE}%{$reset_color%}'
fi

if type "kubectl" >/dev/null; then
  gen_prompt="$gen_prompt%::$(kube_ps1)"
fi

export RPROMPT=$gen_prompt
