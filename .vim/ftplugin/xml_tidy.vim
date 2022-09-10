setlocal equalprg=tidy\ -q\ -m\ -i\ -xml\ --show-errors\ 0\ -w\ 120
set tabstop=2
set shiftwidth=2
let Tlist_Ctags_Cmd = 'ctags --langmap=xml:.xml'
let Tlist_racket_settings = 'xml;d:Definition'
com! FormatXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
nnoremap = :FormatXML<Cr>
