# Environment variables

export USERPROFILE=/mnt/c/Users/`whoami`
EDITOR="vim"
# If we can, use neovim
[ -x /usr/bin/nvim ] && EDITOR=nvim
export EDITOR
export VISUAL=$EDITOR

export HISTCONTROL="ignoreboth:erasedups"
export HISTFILE="${HOME}/.local/history.$(uname -n)"
export HISTSIZE=2000
export HISTIGNORE="&:ls:[bf]g:exit:history:clear:ll:gs"

export PATH=${HOME}/.local/bin:${PATH}

# Fix PATH variable dupes and avoid conflicts with Windows pyenv
if UPDATED_PATH=$(echo $PATH | tr ':' '\012' | uniq | grep -v pyenv | tr '\012' ':'); then
    export PATH=$UPDATED_PATH
else
    echo "WARNING: cannot clean PATH variable"
fi

