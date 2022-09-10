" Based on http://stackoverflow.com/questions/2193157/vim-simple-steps-to-create-syntax-highlight-file-for-logfiles

" Creates a keyword ERROR and puts it in the highlight group logError
:syn keyword logError ERROR
:syn keyword logError FATAL
:syn keyword logWarn WARN
":syn keyword logWarn WARNING

" Creates a match on the date and puts in the highlight group logDate.
" The nextgroup and skipwhite makes vim look for logTime after the match.
:syn match logDate /^\(\d\{2,4}[\/-]\?\)\?\d\{2}[\/-]\?\d\{2}/ nextgroup=logTime skipwhite
" Creates a match on the time (but only if it follows the date)
:syn match logTime /\d\{2}:\d\{2}:\d\{2}\([,:]\d\+\)\?/
" Creates a match on message that contain ERROR or WARN. 
":syn match logErrorMsg contains=logError
":syn match logWarnMsg contains=logWarn


" Now make them appear:
" Link just links logError to the colouring for error
hi link logError Error
hi link logWarn Todo
" Time stamp will show the same as statements in code.
hi link logDate Statement
hi link logTime Statement
