" Maps terminal colors to vim for consistency.
" :so $VIMRUNTIME/syntax/hitest.vim
" :so $VIMRUNTIME/syntax/colortest.vim

" 0 — black        8 — darkgray
" 1 — darkred      9 — red
" 2 — darkgreen   10 — green
" 3 — brown       11 — yellow
" 4 — darkblue    12 — blue
" 5 — darkmagenta 13 — magenta
" 6 — darkcyan    14 — cyan
" 7 — lightgray   15 — white 

highlight Comment        ctermfg=green
highlight Conceal        ctermfg=lightgray ctermbg=lightgray
highlight Constant       ctermfg=brown
highlight CursorColumn   ctermbg=lightgray
highlight CursorLine     cterm=underline
highlight Directory      ctermfg=darkblue
highlight Error          ctermfg=white ctermbg=red
highlight ErrorMsg       ctermfg=white ctermbg=darkred
highlight Identifier     cterm=NONE ctermfg=cyan
highlight Ignore         ctermfg=white
highlight IncSearch      cterm=reverse
highlight LineNr         ctermfg=darkgrey ctermbg=NONE
highlight MatchParen     ctermbg=cyan
highlight ModeMsg        cterm=bold
highlight MoreMsg        ctermfg=darkgreen
highlight NonText        ctermfg=blue
highlight Normal         ctermbg=NONE ctermfg=lightgray
highlight PmenuSbar      ctermbg=darkgray
highlight PmenuThumb     ctermbg=black
highlight PreProc        ctermfg=darkmagenta
highlight Question       ctermfg=6
highlight Special        ctermfg=darkmagenta
highlight SpecialKey     ctermfg=darkblue
highlight SpellBad       ctermbg=red
highlight SpellLocal     ctermbg=cyan
highlight SpellRare      ctermbg=magenta
highlight Statement      ctermfg=darkblue cterm=NONE
highlight TabLine        cterm=underline ctermfg=black ctermbg=lightgray
highlight TabLineFill    cterm=reverse
highlight TabLineSel     cterm=bold
highlight TermCursor     cterm=reverse
highlight Title          ctermfg=darkmagenta
highlight Todo           ctermfg=black ctermbg=yellow
highlight Type           ctermfg=darkgreen
highlight Underlined     cterm=underline ctermfg=darkmagenta
highlight WarningMsg     ctermfg=darkred
highlight WildMenu       ctermfg=black ctermbg=yellow
