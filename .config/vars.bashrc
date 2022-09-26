# Environment variables

export USERPROFILE=/mnt/c/Users/`whoami`
[ -f /usr/bin/vim ] && EDITOR=nvim
export EDITOR
export VISUAL=$EDITOR

export HISTCONTROL="ignorespace:ignoredups:erasedups"
export HISTSIZE=2000
