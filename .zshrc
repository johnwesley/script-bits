# ------------------------------------------------------------------------
# Export PATH
export PATH="/opt/homebrew/bin:$HOME/bin:$PATH"

# Homebrew environment setup (make sure brew is in your PATH first)
# ------------------------------------------------------------------------
# Recommended by Homebrew. Calls brew shellenv to set PATH and FPATH correctly.
eval "$(brew shellenv)"

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Select a theme (default: robbyrussell)
ZSH_THEME="robbyrussell"

# -----------------------
# Plugins
# -----------------------
# Add plugins you want to use. For now, we only enable the git plugin.
plugins=(git kubectl)

# Load Oh My Zsh framework and plugins
source "$ZSH/oh-my-zsh.sh"
source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
export KUBE_PS1_SYMBOL_USE_IMG=true
PS1='$(kube_ps1)'$PS1

# -----------------------
# User Configuration
# -----------------------

# AWS CLI completion
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/opt/homebrew/bin/aws_completer' aws

# AWS Profile switch
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

# ---- AWS profile completion for `awsuse` ----
_awsuse() {
    # Capture the list of profiles for autocompletion
    local -a profiles
    profiles=($(aws configure list-profiles 2>/dev/null))
    compadd "${profiles[@]}"
    return 0
}
compdef _awsuse awsuse

# Source custom aliases (make sure aliases.zsh is in the correct location)
[[ -f "$ZSH_CUSTOM/aliases.zsh" ]] && source "$ZSH_CUSTOM/aliases.zsh"
