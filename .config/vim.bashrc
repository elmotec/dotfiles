# vim.bashrc

# Set EDITOR variable to neovim, else vim
[[ -z "$EDITOR"&& -x $(which nvim) ]] && export EDITOR=$(which nvim)
[[ -z "$EDITOR"&& -x $(which vim) ]] && export EDITOR=$(which vim)
export VISUAL=$EDITOR

# Needed for Startify to work
[[ -d $HOME/.local/share/vim/files/ ]] || mkdir -p $HOME/.local/share/vim/files/

