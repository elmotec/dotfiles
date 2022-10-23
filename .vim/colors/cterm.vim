" Maps terminal colors to vim for consistency. Use numbers for it to work.
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

highlight Comment        ctermfg=2
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
highlight LineNr         ctermfg=darkgrey ctermbg=NONE
highlight MatchParen     ctermbg=14
highlight ModeMsg        cterm=bold
highlight MoreMsg        ctermfg=2
highlight NonText        ctermfg=12
highlight Normal         ctermbg=NONE ctermfg=7
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
highlight WarningMsg     ctermfg=1
highlight WildMenu       ctermfg=0 ctermbg=11
highlight! link Folded LineNr

" for Diffs
highlight DiffText ctermfg=15 ctermbg=3 cterm=NONE
highlight DiffAdd ctermfg=NONE ctermbg=8 cterm=NONE
highlight DiffDelete ctermfg=8 ctermbg=NONE cterm=NONE
highlight DiffChange ctermfg=NONE ctermbg=8 cterm=NONE

