setlocal equalprg=tidy\ -q\ -m\ -i\ -xml\ --show-errors\ 0\ -w\ 120
set tabstop=2
set shiftwidth=2
let Tlist_Ctags_Cmd = 'ctags --langmap=xml:.xml'
let Tlist_racket_settings = 'xml;d:Definition'

