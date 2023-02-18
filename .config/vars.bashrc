# Environment variables

USERPROFILE=/mnt/c/Users/`whoami`
EDITOR="vim"
# If we can, use neovim
[ -x /usr/bin/nvim ] && EDITOR=nvim
VISUAL=$EDITOR

PATH=${HOME}/.local/bin:${PATH}

# Fix PATH variable dupes and avoid conflicts with Windows pyenv
if UPDATED_PATH=$(echo $PATH | tr ':' '\012' | uniq | grep -v pyenv | tr '\012' ':'); then
    PATH=$UPDATED_PATH
else
    echo "WARNING: cannot clean PATH variable"
fi

