"VIM ressource file for python

if exists("g:loaded_python")
    finish
endif
let g:loaded_python = 1

" Code folding.
set foldmethod=indent
set foldlevel=99

compiler pyunit
" MakeGreen function expects makeprg to be defined as python (not python\ %).
set makeprg=python.exe 

" Auto completion
set omnifunc=pythoncomplete#Complete
set completeopt=menuone,longest,preview

" Auto replace pdb
iabbrev pdb import pdb; pdb.set_trace()

" Convert files to utf-8
set fileencoding=utf-8

" Vim pydoc customizations.
let g:pydoc_use_drop=1

