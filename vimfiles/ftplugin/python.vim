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
set makeprg=python

" Auto completion
set omnifunc=pythoncomplete#Complete
set completeopt=menuone,longest,preview

" Specific for Python
" Remaps pep8 to ,8.
let g:pep8_map='<Leader>8'
let g:pylint_map='<Leader>c'

" Prevents pyflakes from using quickfix window.
"let g:pyflakes_use_quickfix=0

" Sets super tab defaults auto completion.
"let g:SuperTabDefaultCompletionType = "context"

