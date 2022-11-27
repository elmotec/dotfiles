" Maps terminal colors to vim for consistency. Use numbers for it to work.
" :so $VIMRUNTIME/syntax/hitest.vim
" :so $VIMRUNTIME/syntax/colortest.vim

" 0 — background (black)
" 1 — darkred
" 2 — darkgreen
" 3 — brown
" 4 — darkblue
" 5 — darkmagenta
" 6 — darkcyan
" 7 — text (white, lower left in terminal settings)
" 8 — accent background (bright black, upper right in terminal settings)
" 9 — red
" 10 — green
" 11 — yellow
" 12 — blue
" 13 — magenta
" 14 — cyan
" 15 — accent text (white/brightwhite)
"
" For windows terminal:
" background: darkgrey (swap white and black)
" foreground: lightgray (swap lightgray and darkgray)
" cursor color: to taste 

highlight Comment        ctermfg=10
highlight Conceal        ctermfg=7 ctermbg=7
highlight Constant       ctermfg=3
highlight CursorColumn   ctermbg=7
highlight CursorLine     cterm=underline
highlight Directory      ctermfg=4
highlight Error          ctermfg=15 ctermbg=9
highlight ErrorMsg       ctermfg=15 ctermbg=1
highlight Identifier     cterm=NONE ctermfg=14
highlight Ignore         ctermfg=15
highlight IncSearch      cterm=reverse
highlight CursorLineNr   ctermfg=11
highlight LineNr         ctermfg=8
highlight MatchParen     ctermbg=14
highlight MoreMsg        ctermfg=2
highlight NonText        ctermfg=12
highlight Normal         ctermfg=7
highlight Pmenu          ctermbg=7
highlight PmenuSbar      ctermbg=8
highlight PmenuThumb     ctermbg=0
highlight PreProc        ctermfg=5
highlight Question       ctermfg=6
highlight Special        ctermfg=5
highlight SpecialKey     ctermfg=4
highlight SpellBad       ctermbg=9
highlight SpellLocal     ctermbg=14
highlight SpellRare      ctermbg=13
highlight Statement      ctermfg=4 cterm=NONE
highlight TabLine        cterm=underline ctermfg=0 ctermbg=7
highlight TabLineFill    cterm=reverse
highlight TabLineSel     cterm=bold
highlight TermCursor     cterm=reverse
highlight Title          ctermfg=5
highlight Todo           ctermfg=0 ctermbg=11
highlight Type           ctermfg=2
highlight Underlined     cterm=underline ctermfg=5
highlight WarningMsg     ctermfg=13 ctermbg=NONE
highlight WildMenu       ctermfg=0 ctermbg=11
highlight! Pmenu          ctermfg=7 ctermbg=0
highlight! PmenuSelect    ctermfg=13 ctermbg=0
" Exclamation mark to overwrite any existing highlight
highlight! link Folded LineNr
highlight! link DiagnosticError ErrorMsg
highlight! link DiagnosticWarn WarningMsg
highlight! link DiagnosticInHintMsg InfoMsg
highlight! link DiagnosticHint HintMsg

" for Diffs
highlight DiffText ctermfg=15 ctermbg=3 cterm=NONE
highlight DiffAdd ctermfg=NONE ctermbg=8 cterm=NONE
highlight DiffDelete ctermfg=7 ctermbg=NONE cterm=NONE
highlight DiffChange ctermfg=NONE ctermbg=7 cterm=NONE

