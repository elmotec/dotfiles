" Forwards to vimrc for now
" From :help nvim-from-vim
set runtimepath^=~/vimfiles runtimepath+=~/vimfiles/after
let &packpath = &runtimepath
source ~/vimfiles/vimrc
