# Environment variables

# For Windows wsl.
USERPROFILE=/mnt/c/Users/$(whoami)

# Set EDITOR variable to neovim, else vim
[[ -z ${EDITOR:-} && -x $(which nvim) ]] && export EDITOR=$(which nvim)
[[ -z ${EDITOR:-} && -x $(which vim) ]] && export EDITOR=$(which vim)
export VISUAL=$EDITOR

PATH=${HOME}/bin:${HOME}/.local/bin:${HOME}/lib:${HOME}/.local/lib:${HOME}/.npm-global/bin:${PATH}

CDPATH=${CDPATH}:${HOME}/dev:${HOME}/dev/tomscore

# Fix PATH variable dupes
if UPDATED_PATH=$(echo $PATH | tr ':' '\012' | uniq | tr '\012' ':'); then
    PATH=$UPDATED_PATH
else
    echo "WARNING: cannot clean PATH variable"
fi
export PATH

return 0
