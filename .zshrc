# ------------------------------------------------------------------------
# Export PATH
export PATH="/opt/homebrew/bin:$HOME/bin:$PATH"

# Homebrew environment setup
# ------------------------------------------------------------------------
# Check if brew exists, then use `brew shellenv`.
if command -v brew &>/dev/null; then
    eval "$(brew shellenv)"
fi

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Select a theme (default: robbyrussell)
ZSH_THEME="robbyrussell"

# ------------------------------------------------------------------------
# Plugins
# ------------------------------------------------------------------------
plugins=(git kubectl)

# Oh My Zsh framework
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
fi

# kube-ps1 prompt
if [ -f "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh" ]; then
    source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
    export KUBE_PS1_SYMBOL_USE_IMG=true
    PS1='$(kube_ps1)'$PS1
fi

# ------------------------------------------------------------------------
# User Configuration
# ------------------------------------------------------------------------

# Use zsh's bash completion system
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# AZ CLI completion
if [ -f "$(brew --prefix)/etc/bash_completion.d/az" ]; then
    source "$(brew --prefix)/etc/bash_completion.d/az"
fi

# AWS CLI completion
if [ -f "/opt/homebrew/bin/aws_completer" ]; then
    complete -C '/opt/homebrew/bin/aws_completer' aws
fi

# AWS Profile helper functions
awslist() {
    echo "Available AWS profiles:"
    aws configure list-profiles
}

awsuse() {
    if [ -z "$1" ]; then
        echo "Usage: awsuse <profile-name>"
        return 1
    fi
    export AWS_PROFILE="$1"
    echo "Switched to AWS profile: $AWS_PROFILE"
}

# AWS profile completion for awsuse
_awsuse() {
    local -a profiles
    profiles=($(aws configure list-profiles 2>/dev/null))
    compadd "${profiles[@]}"
    return 0
}
compdef _awsuse awsuse

# Source custom aliases
if [ -f "$ZSH_CUSTOM/aliases.zsh" ]; then
    source "$ZSH_CUSTOM/aliases.zsh"
fi

# Source Nix initialization script
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi