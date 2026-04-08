"VIM ressource file for python

if exists("g:loaded_python")
    finish
endif
let g:loaded_python = 1

compiler pyunit
setlocal makeprg=python\ %:S   " Run a single testcase
" Leverages black for formatting with gq operator
"autocmd FileType python setlocal equalprg='python.exe -m black -q -'
setlocal formatprg=python.exe\ -m\ black\ -q\ -

" Auto replace pdb
iabbrev pdb import pdb; pdb.set_trace()

" Convert files to utf-8
setlocal fileencoding=utf-8

