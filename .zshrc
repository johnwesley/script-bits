# ------------------------------------------------------------------------
# Shell options & history
# ------------------------------------------------------------------------
setopt autocd correct
setopt hist_ignore_all_dups share_history inc_append_history extended_history
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# Quiet down the terminal bell
setopt no_beep

# ------------------------------------------------------------------------
# Homebrew (Apple Silicon)
# NOTE: brew recommends putting this in ~/.zprofile for login shells.
# Keeping here is fine if you mostly use interactive shells.
# ------------------------------------------------------------------------
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ------------------------------------------------------------------------
# Base PATH (zsh array form)
# brew shellenv already adds /opt/homebrew/* for you.
# ------------------------------------------------------------------------
path=(
  $HOME/bin
  $HOME/.local/bin
  $path
)
export PATH

# ------------------------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git kubectl)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ------------------------------------------------------------------------
# Completions
# ------------------------------------------------------------------------
autoload -Uz compinit
COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump-$ZSH_VERSION"
compinit -i -d "$COMPDUMP"

zmodload -i zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=** r:|=**'

# Optional: enable bash-style completions if needed
autoload -Uz bashcompinit

# Azure CLI completion
if command -v az >/dev/null 2>&1; then
  if az help --help 2>/dev/null | grep -qi completion; then
    source <(az completion --zsh)
  elif [[ -f "$(brew --prefix 2>/dev/null)/etc/bash_completion.d/az" ]]; then
    bashcompinit && source "$(brew --prefix)/etc/bash_completion.d/az"
  fi
fi

# AWS CLI completion
if [[ -x /opt/homebrew/bin/aws_completer ]]; then
  bashcompinit
  complete -C '/opt/homebrew/bin/aws_completer' aws
fi

# ------------------------------------------------------------------------
# kube-ps1 (integrate with zsh PROMPT, not PS1)
# ------------------------------------------------------------------------
if [[ -f "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh" ]]; then
  source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
  export KUBE_PS1_SYMBOL_USE_IMG=true
  PROMPT='$(kube_ps1) '"$PROMPT"
  kubeoff
fi

# ------------------------------------------------------------------------
# Nix (if installed)
# ------------------------------------------------------------------------
if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# ------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------
[[ -f "$ZSH_CUSTOM/aliases.zsh" ]] && source "$ZSH_CUSTOM/aliases.zsh"

# Ensure `claude` points to the correct binary
if alias claude >/dev/null 2>&1; then
  unalias claude
fi
if [[ -x "$HOME/.local/bin/claude" ]]; then
  alias claude="$HOME/.local/bin/claude"
fi

# ------------------------------------------------------------------------
# AWS profile helpers
# ------------------------------------------------------------------------
awslist() {
  echo "Available AWS profiles:"
  aws configure list-profiles 2>/dev/null
}
awsuse() {
  if [[ -z "$1" ]]; then
    echo "Usage: awsuse <profile-name>"
    return 1
  fi
  export AWS_PROFILE="$1"
  echo "Switched to AWS profile: $AWS_PROFILE"
}
_awsuse() {
  local -a profiles
  profiles=($(aws configure list-profiles 2>/dev/null))
  compadd -- "${profiles[@]}"
}
compdef _awsuse awsuse

# ------------------------------------------------------------------------
# Optional extras (auto-activated if installed)
# ------------------------------------------------------------------------
# fzf
if [[ -d /opt/homebrew/opt/fzf ]]; then
  [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh   ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# ------------------------------------------------------------------------
# Secrets (NEVER commit this file)
# ------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.secrets" ]] && source "$HOME/.zshrc.secrets"