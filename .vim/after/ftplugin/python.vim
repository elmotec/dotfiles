"VIM ressource file for python

if exists("g:loaded_python")
    finish
endif
let g:loaded_python = 1

" MakeGreen function expects makeprg to be defined as python (not python\ %).
compiler pyunit
set makeprg=python.exe\ -m\ unittest\ -\ 2>NUL

" Leverages black for formatting with gq operator
"autocmd FileType python setlocal equalprg='python.exe -m black -q -'
set formatprg=python.exe\ -m\ black\ -q\ -
set equalprg=python.exe\ -m\ black\ -q\ -

" Auto replace pdb
iabbrev pdb import pdb; pdb.set_trace()

" Convert files to utf-8
set fileencoding=utf-8

" Python documentation style. 
let g:ultisnips_python_style="sphinx"

