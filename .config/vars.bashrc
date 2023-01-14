# Environment variables

export USERPROFILE=/mnt/c/Users/`whoami`
EDITOR="vim"
# If we can, use neovim
[ -f /usr/bin/vim ] && EDITOR=nvim
export EDITOR
export VISUAL=$EDITOR

export HISTCONTROL="ignoreboth:erasedups"
export HISTFILE="${HOME}/.local/history.$(uname -n)"
export HISTSIZE=2000

# Fix PATH variable to avoid conflicts with Windows pyenv
PATH=$(echo $PATH | tr ':' '\012' | grep -v pyenv | tr '\012' ':')
export PATH
