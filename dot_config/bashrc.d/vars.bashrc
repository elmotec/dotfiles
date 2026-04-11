# Environment variables

# For Windows wsl.
USERPROFILE=/mnt/c/Users/$(whoami)

# Set EDITOR variable to neovim, else vim
[[ -z ${EDITOR:-} && -x $(which nvim) ]] && export EDITOR=$(which nvim)
[[ -z ${EDITOR:-} && -x $(which vim) ]] && export EDITOR=$(which vim)
export VISUAL=$EDITOR

PATH=${HOME}/.local/bin:${HOME}/.local/lib:${HOME}/.npm-global/bin:/snap/bin/:${PATH}
CDPATH=${CDPATH}:${HOME}/dev:${HOME}/dev/tomscore

# Fix PATH variable dupes
if UPDATED_PATH=$(echo $PATH | tr ':' '\012' | uniq | tr '\012' ':'); then
    PATH=$UPDATED_PATH
else
    echo "WARNING: cannot clean PATH variable"
fi
export PATH

export PAGER=less
export OLLAMA_API_BASE=http://beelink1:11434

return 0
