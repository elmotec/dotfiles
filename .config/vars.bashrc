# Environment variables

USERPROFILE=/mnt/c/Users/`whoami`
# Set EDITOR variable to neovim, else vim
[ -z "$EDITOR" -a -x nvim ] && export EDITOR=nvim
[ -z "$EDITOR" -a -x vim ] && export EDITOR=vim
export VISUAL=$EDITOR

PATH=${HOME}/.local/bin:${PATH}

# Fix PATH variable dupes and avoid conflicts with Windows pyenv
if UPDATED_PATH=$(echo $PATH | tr ':' '\012' | uniq | grep -v pyenv | tr '\012' ':'); then
    PATH=$UPDATED_PATH
else
    echo "WARNING: cannot clean PATH variable"
fi
export PATH

