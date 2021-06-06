"VIM ressource file for python

if exists("g:loaded_python")
    finish
endif
let g:loaded_python = 1

" Code folding.
"set foldexpr=SimpylFold(v:lnum)
"set foldmethod=expr

" MakeGreen function expects makeprg to be defined as python (not python\ %).
compiler pyunit
set makeprg=python.exe\ -m\ unittest\ -\ 2>NUL

" Leverages black for formatting with gq operator
"autocmd FileType python setlocal equalprg='python.exe -m black -q -'
set formatprg=python.exe\ -m\ black\ -q\ -
set equalprg=python.exe\ -m\ black\ -q\ -

" Auto completion
set omnifunc=pythoncomplete#Complete
set completeopt=menuone,longest,preview

" Auto replace pdb
iabbrev pdb import pdb; pdb.set_trace()

" Convert files to utf-8
set fileencoding=utf-8

" Vim pydoc customizations.
let g:pydoc_use_drop=1

" Show column 81 to 9999 as different background.
let &colorcolumn=join(range(81, 9999), ",")

" Python documentation style. 
let g:ultisnips_python_style="sphinx"

