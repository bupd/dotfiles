# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light wbingli/zsh-wakatime

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
# zinit snippet OMZP::tmux
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

## install asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey -s '^F' 'exec sessionizer^M'
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3;5~' kill-word
bindkey  '^[[3~'  delete-char
bindkey '\b'  backward-delete-char
bindkey '\C-h' backward-kill-word
bindkey '<M-Del>' kill-word

# History
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
# setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
# zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias rl='ramalama'
alias pack='pack-cli'
alias vim='sudo -E -s nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias l='ls -al'
# alias c=''
alias :q="exit"
alias ta="tmux a"
alias t="tmux"
alias c="clear"
alias gs="git status"
alias gfp="git fetch && git pull"
alias lz="lazygit"
alias phone="cd /run/user/1000/gvfs/sftp:host=192.168.1.127,port=8022/storage/E65A-C7E4/"
alias clean="yes | pacrmorphans || true; yes | yaclr || true; echo 'deleting docker cache. this may feel stuck but it actually inst stuck'; sudo systemctl stop docker.socket || true; sudo systemctl stop docker || true; sudo rm -rf /var/lib/docker || true; sudo systemctl start docker"
alias dy="dig +short @dns.toys"
alias kns="kubectl config set-context --current --namespace"
alias kctx="kubectx"
alias d="docker"
alias dc="docker compose"
alias refresh-camera="sudo usermod -aG video $USER"

# Neovim SOLOS the Editors
export EDITOR="nvim"

# PATH for binaries
export PATH="$HOME/.local/bin/":$PATH
PATH=$PATH:$HOME/bin
# source /usr/share/nvm/init-nvm.sh

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# GOPATH from arch community
export PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"

eval "$(go env)"

## for talosctl
eval "$(talosctl completion zsh)"

# Shell integrations
eval "$(fzf --zsh)"

# for asdf version manager
# . /opt/asdf-vm/asdf.sh

# nvm completion
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/zsh_completion" ] && \. "$NVM_DIR/zsh_completion"  # This loads nvm zsh_completion

# for dagger harbor push
export REGPASS="Harbor12345"

# Load Angular CLI autocompletion.
# source <(ng completion script)

# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/bupd/s/code/update/google-cloud-sdk/path.zsh.inc' ]; then . '/home/bupd/s/code/update/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/bupd/s/code/update/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/bupd/s/code/update/google-cloud-sdk/completion.zsh.inc'; fi

# changed the ssh private key to 600

# harbor related things
alias buildharborcore="make check_environment versions_prepare compile_core && docker build --build-arg harbor_base_image_version=dev --build-arg harbor_base_namespace=goharbor -f make/photon/core/Dockerfile -t goharbor/harbor-core:dev ."
alias buildharbor-jobservice="make check_environment versions_prepare compile_jobservice && docker build --build-arg harbor_base_image_version=dev --build-arg harbor_base_namespace=goharbor -f make/photon/jobservice/Dockerfile -t goharbor/harbor-jobservice:dev ."
alias buildharbor-registry="make check_environment versions_prepare compile_registryctl && docker build --build-arg harbor_base_image_version=dev --build-arg harbor_base_namespace=goharbor -f make/photon/registryctl/Dockerfile -t goharbor/harbor-registryctl:dev ."

## add alias for your own scripts
airdopes="~/dotfiles/scripts/airdopes"
cputemp="~/dotfiles/scripts/cputemp"
watchtime="~/dotfiles/scripts/watchtime"

# for nvm
# source /usr/share/nvm/init-nvm.sh

# Automatically notify after each command finishes with context
function notify_after_command() {
  # Capture the last executed command
  local cmd=$(fc -ln -1)  # Get the last command executed

  # Check if the last command was successful or failed
  if [ $? -eq 0 ]; then
    notify-send -t 8 "Complete" "Command: '$cmd' has finished successfully."
  else
    notify-send "Task Failed" "Command: '$cmd' failed."
  fi
}

# Call the function after each command
PROMPT_COMMAND="notify_after_command"

precmd() { eval "$PROMPT_COMMAND" }

