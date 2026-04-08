" vi:syntax=vim

" base16-vim (https://github.com/chriskempson/base16-vim)
" by Chris Kempson (http://chriskempson.com)
" {{scheme-name}} scheme by {{scheme-author}}

" Maps terminal colors to vim for consistency. Use numbers for it to work.
" :so $VIMRUNTIME/syntax/hitest.vim for syntax hilights
" :so $VIMRUNTIME/syntax/colortest.vim for color names
" This enables the coresponding base16-shell script to run so that
" :colorscheme works in terminals supported by base16-shell scripts
" User must set this variable in .vimrc
"   let g:base16_shell_path=base16-builder/output/shell/
"if !has("gui_running")
"  if exists("g:base16_shell_path")
"    execute "silent !/bin/sh ".g:base16_shell_path."/base16-{{scheme-slug}}.sh"
"  endif
"endif

" GUI color definitions
let s:gui00        = "{{base00-hex}}"  " Neutral 00
let g:base16_gui00 = "{{base00-hex}}"
let s:gui01        = "{{base01-hex}}"  " Neutral 01
let g:base16_gui01 = "{{base01-hex}}"
let s:gui02        = "{{base02-hex}}"  " Neutral 02
let g:base16_gui02 = "{{base02-hex}}"
let s:gui03        = "{{base03-hex}}"  " Neutral 03
let g:base16_gui03 = "{{base03-hex}}"
let s:gui04        = "{{base04-hex}}"  " Neutral 04
let g:base16_gui04 = "{{base04-hex}}"
let s:gui05        = "{{base05-hex}}"  " Neutral 05
let g:base16_gui05 = "{{base05-hex}}"
let s:gui06        = "{{base06-hex}}"  " Neutral 06
let g:base16_gui06 = "{{base06-hex}}"
let s:gui07        = "{{base07-hex}}"  " Neutral 07
let g:base16_gui07 = "{{base07-hex}}"
let s:gui08        = "{{base08-hex}}"  " Bright red
let g:base16_gui08 = "{{base08-hex}}"
let s:gui09        = "{{base09-hex}}"
let g:base16_gui09 = "{{base09-hex}}"
let s:gui0A        = "{{base0A-hex}}"
let g:base16_gui0A = "{{base0A-hex}}"
let s:gui0B        = "{{base0B-hex}}"  " Bright green
let g:base16_gui0B = "{{base0B-hex}}"
let s:gui0C        = "{{base0C-hex}}"
let g:base16_gui0C = "{{base0C-hex}}"
let s:gui0D        = "{{base0D-hex}}"
let g:base16_gui0D = "{{base0D-hex}}"
let s:gui0E        = "{{base0E-hex}}"
let g:base16_gui0E = "{{base0E-hex}}"
let s:gui0F        = "{{base0F-hex}}"
let g:base16_gui0F = "{{base0F-hex}}"

" Terminal color definitions
let s:cterm00        = "00"  " Neutral 00
let g:base16_cterm00 = "00"
let s:cterm03        = "08"  " Neutral 03
let g:base16_cterm03 = "08"
let s:cterm05        = "07"  " Neutral 05
let g:base16_cterm05 = "07"
let s:cterm07        = "15" " Neutral 07
let g:base16_cterm07 = "15"
let s:cterm08        = "01"  " Bright red
let g:base16_cterm08 = "01"
let s:cterm0A        = "03"
let g:base16_cterm0A = "03"
let s:cterm0B        = "02"  " Bright green
let g:base16_cterm0B = "02"
let s:cterm0C        = "06"
let g:base16_cterm0C = "06"
let s:cterm0D        = "04"
let g:base16_cterm0D = "04"
let s:cterm0E        = "05"
let g:base16_cterm0E = "05"
if exists("base16colorspace") && base16colorspace == "256"
  let s:cterm01        = "18"  " Neutral 01
  let g:base16_cterm01 = "18"
  let s:cterm02        = "19"  " Neutral 02
  let g:base16_cterm02 = "19"
  let s:cterm04        = "20"  " Neutral 04
  let g:base16_cterm04 = "20"
  let s:cterm06        = "21"  " Neutral 06
  let g:base16_cterm06 = "21"
  let s:cterm09        = "16"
  let g:base16_cterm09 = "16"
  let s:cterm0F        = "17"
  let g:base16_cterm0F = "17"
else
  let s:cterm01        = "10"  " Neutral 01
  let g:base16_cterm01 = "10"
  let s:cterm02        = "11"  " Neutral 02
  let g:base16_cterm02 = "11"
  let s:cterm04        = "12"  " Neutral 04
  let g:base16_cterm04 = "12"
  let s:cterm06        = "13"  " Neutral 06
  let g:base16_cterm06 = "13"
  let s:cterm09        = "09"
  let g:base16_cterm09 = "09"
  let s:cterm0F        = "14"
  let g:base16_cterm0F = "14"
endif

" Neovim terminal colours
if has("nvim")
  let g:terminal_color_0 =  "#000000"
  let g:terminal_color_1 =  "#{{base08-hex}}"
  let g:terminal_color_2 =  "#{{base0B-hex}}"
  let g:terminal_color_3 =  "#{{base0A-hex}}"
  let g:terminal_color_4 =  "#{{base0D-hex}}"
  let g:terminal_color_5 =  "#{{base0E-hex}}"
  let g:terminal_color_6 =  "#{{base0C-hex}}"
  let g:terminal_color_7 =  "#{{base05-hex}}"
  let g:terminal_color_8 =  "#{{base03-hex}}"
  let g:terminal_color_9 =  "#{{base08-hex}}"
  let g:terminal_color_10 = "#{{base0B-hex}}"
  let g:terminal_color_11 = "#{{base0A-hex}}"
  let g:terminal_color_12 = "#{{base0D-hex}}"
  let g:terminal_color_13 = "#{{base0E-hex}}"
  let g:terminal_color_14 = "#{{base0C-hex}}"
  let g:terminal_color_15 = "#{{base07-hex}}"
  let g:terminal_color_background = g:terminal_color_0
  let g:terminal_color_foreground = g:terminal_color_5
  if &background == "light"
    let g:terminal_color_background = g:terminal_color_7
    let g:terminal_color_foreground = g:terminal_color_2
  endif
elseif has("terminal")
  let g:terminal_ansi_colors = [
        \ "#{{base00-hex}}",
        \ "#{{base08-hex}}",
        \ "#{{base0B-hex}}",
        \ "#{{base0A-hex}}",
        \ "#{{base0D-hex}}",
        \ "#{{base0E-hex}}",
        \ "#{{base0C-hex}}",
        \ "#{{base05-hex}}",
        \ "#{{base03-hex}}",
        \ "#{{base08-hex}}",
        \ "#{{base0B-hex}}",
        \ "#{{base0A-hex}}",
        \ "#{{base0D-hex}}",
        \ "#{{base0E-hex}}",
        \ "#{{base0C-hex}}",
        \ "#{{base07-hex}}",
        \ ]
endif

" Theme setup
hi clear
syntax reset
let g:colors_name = "base16-{{scheme-slug}}"

" Highlighting function
" Optional variables are attributes and guisp
function! g:Base16hi(group, guifg, guibg, ctermfg, ctermbg, ...)
  let l:attr = get(a:, 1, "")
  let l:guisp = get(a:, 2, "")

  " See :help highlight-guifg
  let l:gui_special_names = ["NONE", "bg", "background", "fg", "foreground"]

  if a:guifg != ""
    if index(l:gui_special_names, a:guifg) >= 0
      exec "hi " . a:group . " guifg=" . a:guifg
    else
      exec "hi " . a:group . " guifg=#" . a:guifg
    endif
  endif
  if a:guibg != ""
    if index(l:gui_special_names, a:guibg) >= 0
      exec "hi " . a:group . " guibg=" . a:guibg
    else
      exec "hi " . a:group . " guibg=#" . a:guibg
    endif
  endif
  if a:ctermfg != ""
    exec "hi " . a:group . " ctermfg=" . a:ctermfg
  endif
  if a:ctermbg != ""
    exec "hi " . a:group . " ctermbg=" . a:ctermbg
  endif
  if l:attr != ""
    exec "hi " . a:group . " gui=" . l:attr . " cterm=" . l:attr
  endif
  if l:guisp != ""
    if index(l:gui_special_names, l:guisp) >= 0
      exec "hi " . a:group . " guisp=" . l:guisp
    else
      exec "hi " . a:group . " guisp=#" . l:guisp
    endif
  endif
endfunction


fun <sid>hi(group, guifg, guibg, ctermfg, ctermbg, attr, guisp)
  call g:Base16hi(a:group, a:guifg, a:guibg, a:ctermfg, a:ctermbg, a:attr, a:guisp)
endfun

" Vim editor colors
call <sid>hi("Normal",        s:gui05, s:gui00, s:cterm05, s:cterm00, "", "")
call <sid>hi("Bold",          "", "", "", "", "bold", "")
call <sid>hi("Debug",         s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("Directory",     s:gui0D, "", s:cterm0D, "", "", "")
call <sid>hi("Error",         s:gui00, s:gui08, s:cterm00, s:cterm08, "", "")
call <sid>hi("ErrorMsg",      s:gui07, s:gui00, s:cterm07, s:cterm00, "bold", "")
call <sid>hi("Exception",     s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("FoldColumn",    s:gui0C, s:gui01, s:cterm0C, s:cterm01, "", "")
call <sid>hi("Folded",        s:gui03, s:gui01, s:cterm03, s:cterm01, "", "")
call <sid>hi("IncSearch",     s:gui01, s:gui09, s:cterm01, s:cterm09, "none", "")
call <sid>hi("Italic",        "", "", "", "", "italic", "")
call <sid>hi("Macro",         s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("MatchParen",    "", s:gui03, "", s:cterm03,  "", "")
call <sid>hi("ModeMsg",       s:gui0B, "", s:cterm0B, "", "", "")
call <sid>hi("MoreMsg",       s:gui0B, "", s:cterm0B, "", "", "")
call <sid>hi("Question",      s:gui0D, "", s:cterm0D, "", "", "")
call <sid>hi("Search",        s:gui01, s:gui0A, s:cterm01, s:cterm0A,  "", "")
call <sid>hi("Substitute",    s:gui01, s:gui0A, s:cterm01, s:cterm0A, "none", "")
call <sid>hi("SpecialKey",    s:gui03, "", s:cterm03, "", "", "")
call <sid>hi("TooLong",       s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("Underlined",    s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("Visual",        "", s:gui02, "", s:cterm02, "", "")
call <sid>hi("VisualNOS",     s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("WarningMsg",    s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("WildMenu",      s:gui08, s:gui0A, s:cterm08, "", "", "")
call <sid>hi("Title",         s:gui0D, "", s:cterm0D, "", "none", "")
call <sid>hi("Conceal",       s:gui0D, s:gui00, s:cterm0D, s:cterm00, "", "")
call <sid>hi("Cursor",        s:gui00, s:gui05, s:cterm00, s:cterm05, "", "")
call <sid>hi("NonText",       s:gui03, "", s:cterm03, "", "", "")
call <sid>hi("LineNr",        s:gui03, s:gui01, s:cterm03, s:cterm01, "", "")
call <sid>hi("SignColumn",    s:gui03, s:gui01, s:cterm03, s:cterm01, "", "")
call <sid>hi("StatusLine",    s:gui04, s:gui02, s:cterm04, s:cterm02, "none", "")
call <sid>hi("StatusLineNC",  s:gui03, s:gui01, s:cterm03, s:cterm01, "none", "")
call <sid>hi("VertSplit",     s:gui02, s:gui02, s:cterm02, s:cterm02, "none", "")
call <sid>hi("ColorColumn",   "", s:gui01, "", s:cterm01, "none", "")
call <sid>hi("CursorColumn",  "", s:gui01, "", s:cterm01, "none", "")
call <sid>hi("CursorLine",    "", s:gui01, "", s:cterm01, "none", "")
call <sid>hi("CursorLineNr",  s:gui04, s:gui01, s:cterm04, s:cterm01, "", "")
call <sid>hi("QuickFixLine",  "", s:gui01, "", s:cterm01, "none", "")
call <sid>hi("PMenu",         s:gui05, s:gui01, s:cterm05, s:cterm01, "none", "")
call <sid>hi("PMenuSel",      s:gui01, s:gui05, s:cterm01, s:cterm05, "", "")
call <sid>hi("TabLine",       s:gui03, s:gui01, s:cterm03, s:cterm01, "none", "")
call <sid>hi("TabLineFill",   s:gui03, s:gui01, s:cterm03, s:cterm01, "none", "")
call <sid>hi("TabLineSel",    s:gui0B, s:gui01, s:cterm0B, s:cterm01, "none", "")

" Standard syntax highlighting
call <sid>hi("Boolean",      s:gui09, "", s:cterm09, "", "", "")
call <sid>hi("Character",    s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("Comment",      s:gui03, "", s:cterm03, "", "italic", "")
call <sid>hi("Conditional",  s:gui0E, "", s:cterm0E, "", "", "")
call <sid>hi("Constant",     s:gui09, "", s:cterm09, "", "", "")
call <sid>hi("Define",       s:gui0E, "", s:cterm0E, "", "none", "")
call <sid>hi("Delimiter",    s:gui0F, "", s:cterm0F, "", "", "")
call <sid>hi("Float",        s:gui09, "", s:cterm09, "", "", "")
call <sid>hi("Function",     s:gui0D, "", s:cterm0D, "", "", "")
call <sid>hi("Identifier",   s:gui08, "", s:cterm08, "", "none", "")
call <sid>hi("Include",      s:gui0D, "", s:cterm0D, "", "", "")
call <sid>hi("Keyword",      s:gui0E, "", s:cterm0E, "", "", "")
call <sid>hi("Label",        s:gui0A, "", s:cterm0A, "", "", "")
call <sid>hi("Number",       s:gui09, "", s:cterm09, "", "", "")
call <sid>hi("Operator",     s:gui05, "", s:cterm05, "", "none", "")
call <sid>hi("PreProc",      s:gui0A, "", s:cterm0A, "", "", "")
call <sid>hi("Repeat",       s:gui0A, "", s:cterm0A, "", "", "")
call <sid>hi("Special",      s:gui0C, "", s:cterm0C, "", "", "")
call <sid>hi("SpecialChar",  s:gui0F, "", s:cterm0F, "", "", "")
call <sid>hi("Statement",    s:gui08, "", s:cterm08, "", "", "")
call <sid>hi("StorageClass", s:gui0A, "", s:cterm0A, "", "", "")
call <sid>hi("String",       s:gui0B, "", s:cterm0B, "", "", "")
call <sid>hi("Structure",    s:gui0E, "", s:cterm0E, "", "", "")
call <sid>hi("Tag",          s:gui0A, "", s:cterm0A, "", "", "")
call <sid>hi("Todo",         s:gui0A, s:gui01, s:cterm0A, s:cterm01, "", "")
call <sid>hi("Type",         s:gui0A, "", s:cterm0A, "", "none", "")
call <sid>hi("Typedef",      s:gui0A, "", s:cterm0A, "", "", "")

" C highlighting
call <sid>hi("cOperator",   s:cterm0C, "", s:cterm0C, "", "", "")
call <sid>hi("cPreCondit",  s:cterm0E, "", s:cterm0E, "", "", "")

" C# highlighting
call <sid>hi("csClass",                 s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("csAttribute",             s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("csModifier",              s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("csType",                  s:cterm08, "", s:cterm08, "", "", "")
call <sid>hi("csUnspecifiedStatement",  s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("csContextualStatement",   s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("csNewDecleration",        s:cterm08, "", s:cterm08, "", "", "")

" CSS highlighting
call <sid>hi("cssBraces",      s:cterm05, "", s:cterm05, "", "", "")
call <sid>hi("cssClassName",   s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("cssColor",       s:cterm0C, "", s:cterm0C, "", "", "")

" Diff highlighting
" Git
call <sid>hi("Added",      s:gui0B, "",  s:cterm0B, "", "", "")
call <sid>hi("Removed",   s:gui08, "",  s:cterm08, "", "", "")
call <sid>hi("Changed",   s:gui04, "",  s:cterm04, "", "", "")
call <sid>hi("DiffAdd",      s:gui0B, "",  s:cterm0B, "", "", "")
call <sid>hi("DiffAdded",    s:gui0B, "",  s:cterm0B, "", "", "")
call <sid>hi("DiffChange",   s:gui04, "",  s:cterm04, "", "", "")
call <sid>hi("DiffDelete",   s:gui08, "",  s:cterm08, "", "strikethrough", "")
" Highlight text changes inside a changed line
call <sid>hi("DiffText",     s:gui06, s:gui01,  s:cterm06, s:cterm01, "", "")
call <sid>hi("DiffFile",     s:gui08, "",  s:cterm08, "", "", "")
call <sid>hi("DiffNewFile",  s:gui0B, "",  s:cterm0B, "", "", "")
call <sid>hi("DiffLine",     s:gui0D, "",  s:cterm0D, "", "", "")

" Git highlighting
call <sid>hi("gitcommitOverflow",       s:cterm08, "", s:cterm08, "", "", "")
call <sid>hi("gitcommitSummary",        s:cterm0B, "", s:cterm0B, "", "", "")
call <sid>hi("gitcommitUntracked",      s:cterm03, "", s:cterm03, "", "", "")
call <sid>hi("gitcommitDiscarded",      s:cterm03, "", s:cterm03, "", "", "")
call <sid>hi("gitcommitSelected",       s:cterm03, "", s:cterm03, "", "", "")
call <sid>hi("gitcommitHeader",         s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("gitcommitSelectedType",   s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("gitcommitUnmergedType",   s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("gitcommitDiscardedType",  s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("gitcommitBranch",         s:cterm09, "", s:cterm09, "", "bold", "")
call <sid>hi("gitcommitUntrackedFile",  s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("gitcommitUnmergedFile",   s:cterm08, "", s:cterm08, "", "bold", "")
call <sid>hi("gitcommitDiscardedFile",  s:cterm08, "", s:cterm08, "", "bold", "")
call <sid>hi("gitcommitSelectedFile",   s:cterm0B, "", s:cterm0B, "", "bold", "")

" GitGutter highlighting
call <sid>hi("GitGutterAdd",     s:cterm0B, s:cterm01, s:cterm0B, s:cterm01, "", "")
call <sid>hi("GitGutterChange",  s:cterm0D, s:cterm01, s:cterm0D, s:cterm01, "", "")
call <sid>hi("GitGutterDelete",  s:cterm08, s:cterm01, s:cterm08, s:cterm01, "", "")
call <sid>hi("GitGutterChangeDelete",  s:cterm0E, s:cterm01, s:cterm0E, s:cterm01, "", "")

" HTML highlighting
call <sid>hi("htmlBold",    s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("htmlItalic",  s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("htmlEndTag",  s:cterm05, "", s:cterm05, "", "", "")
call <sid>hi("htmlTag",     s:cterm05, "", s:cterm05, "", "", "")

" JavaScript highlighting
call <sid>hi("javaScript",        s:cterm05, "", s:cterm05, "", "", "")
call <sid>hi("javaScriptBraces",  s:cterm05, "", s:cterm05, "", "", "")
call <sid>hi("javaScriptNumber",  s:cterm09, "", s:cterm09, "", "", "")
" pangloss/vim-javascript highlighting
call <sid>hi("jsOperator",          s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("jsStatement",         s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("jsReturn",            s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("jsThis",              s:cterm08, "", s:cterm08, "", "", "")
call <sid>hi("jsClassDefinition",   s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("jsFunction",          s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("jsFuncName",          s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("jsFuncCall",          s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("jsClassFuncName",     s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("jsClassMethodType",   s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("jsRegexpString",      s:cterm0C, "", s:cterm0C, "", "", "")
call <sid>hi("jsGlobalObjects",     s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("jsGlobalNodeObjects", s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("jsExceptions",        s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("jsBuiltins",          s:cterm0A, "", s:cterm0A, "", "", "")

" LSP highlighting
call <sid>hi("LspDiagnosticsDefaultError", s:cterm08, "", s:cterm08, "", "", "")
call <sid>hi("LspDiagnosticsDefaultWarning", s:cterm09, "", s:cterm09, "", "", "")
call <sid>hi("LspDiagnosticsDefaultHnformation", s:cterm05, "", s:cterm05, "", "", "")
call <sid>hi("LspDiagnosticsDefaultHint", s:cterm03, "", s:cterm03, "", "", "")

" Mail highlighting
call <sid>hi("mailQuoted1",  s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("mailQuoted2",  s:cterm0B, "", s:cterm0B, "", "", "")
call <sid>hi("mailQuoted3",  s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("mailQuoted4",  s:cterm0C, "", s:cterm0C, "", "", "")
call <sid>hi("mailQuoted5",  s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("mailQuoted6",  s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("mailURL",      s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("mailEmail",    s:cterm0D, "", s:cterm0D, "", "", "")

" Markdown highlighting
call <sid>hi("markdownCode",              s:cterm0B, "", s:cterm0B, "", "", "")
call <sid>hi("markdownError",             s:cterm05, s:cterm00, s:cterm05, s:cterm00, "", "")
call <sid>hi("markdownCodeBlock",         s:cterm0B, "", s:cterm0B, "", "", "")
call <sid>hi("markdownHeadingDelimiter",  s:cterm0D, "", s:cterm0D, "", "", "")

" NERDTree highlighting
call <sid>hi("NERDTreeDirSlash",  s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("NERDTreeExecFile",  s:cterm05, "", s:cterm05, "", "", "")

" PHP highlighting
call <sid>hi("phpMemberSelector",  s:cterm05, "", s:cterm05, "", "", "")
call <sid>hi("phpComparison",      s:cterm05, "", s:cterm05, "", "", "")
call <sid>hi("phpParent",          s:cterm05, "", s:cterm05, "", "", "")
call <sid>hi("phpMethodsVar",      s:cterm0C, "", s:cterm0C, "", "", "")

" Python highlighting
call <sid>hi("pythonOperator",  s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("pythonRepeat",    s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("pythonInclude",   s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("pythonStatement", s:cterm0E, "", s:cterm0E, "", "", "")

" Ruby highlighting
call <sid>hi("rubyAttribute",               s:cterm0D, "", s:cterm0D, "", "", "")
call <sid>hi("rubyConstant",                s:cterm0A, "", s:cterm0A, "", "", "")
call <sid>hi("rubyInterpolationDelimiter",  s:cterm0F, "", s:cterm0F, "", "", "")
call <sid>hi("rubyRegexp",                  s:cterm0C, "", s:cterm0C, "", "", "")
call <sid>hi("rubySymbol",                  s:cterm0B, "", s:cterm0B, "", "", "")
call <sid>hi("rubyStringDelimiter",         s:cterm0B, "", s:cterm0B, "", "", "")

" SASS highlighting
call <sid>hi("sassidChar",     s:cterm08, "", s:cterm08, "", "", "")
call <sid>hi("sassClassChar",  s:cterm09, "", s:cterm09, "", "", "")
call <sid>hi("sassInclude",    s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("sassMixing",     s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("sassMixinName",  s:cterm0D, "", s:cterm0D, "", "", "")

" Signify highlighting
call <sid>hi("SignifySignAdd",     s:cterm0B, s:cterm01, s:cterm0B, s:cterm01, "", "")
call <sid>hi("SignifySignChange",  s:cterm0D, s:cterm01, s:cterm0D, s:cterm01, "", "")
call <sid>hi("SignifySignDelete",  s:cterm08, s:cterm01, s:cterm08, s:cterm01, "", "")

" Spelling highlighting
call <sid>hi("SpellBad",     "", "", "", "", "undercurl", "")
call <sid>hi("SpellLocal",   "", "", "", "", "undercurl", "")
call <sid>hi("SpellCap",     "", "", "", "", "undercurl", "")
call <sid>hi("SpellRare",    "", "", "", "", "undercurl", "")

" Startify highlighting
call <sid>hi("StartifyBracket",  s:cterm03, "", s:cterm03, "", "", "")
call <sid>hi("StartifyFile",     s:cterm07, "", s:cterm07, "", "", "")
call <sid>hi("StartifyFooter",   s:cterm03, "", s:cterm03, "", "", "")
call <sid>hi("StartifyHeader",   s:cterm0B, "", s:cterm0B, "", "", "")
call <sid>hi("StartifyNumber",   s:cterm09, "", s:cterm09, "", "", "")
call <sid>hi("StartifyPath",     s:cterm03, "", s:cterm03, "", "", "")
call <sid>hi("StartifySection",  s:cterm0E, "", s:cterm0E, "", "", "")
call <sid>hi("StartifySelect",   s:cterm0C, "", s:cterm0C, "", "", "")
call <sid>hi("StartifySlash",    s:cterm03, "", s:cterm03, "", "", "")
call <sid>hi("StartifySpecial",  s:cterm03, "", s:cterm03, "", "", "")

" Java highlighting
call <sid>hi("javaOperator",     s:cterm0D, "", s:cterm0D, "", "", "")

" Remove functions
delf <sid>hi

" Remove color variables
unlet s:cterm00 s:cterm01 s:cterm02 s:cterm03  s:cterm04  s:cterm05  s:cterm06  s:cterm07  s:cterm08  s:cterm09 s:cterm0A  s:cterm0B  s:cterm0C  s:cterm0D  s:cterm0E  s:cterm0F

" Always rely on the non gui term colors for cterm
"if has('nvim') && v:version >= 800
set notermguicolors
"endif

