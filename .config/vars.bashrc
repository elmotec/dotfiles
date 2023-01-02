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
