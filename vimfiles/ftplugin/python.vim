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

