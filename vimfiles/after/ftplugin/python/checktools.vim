" To change mapping, just put
" let g:pep8_map='whatever'
function! <SID>Pygrep(checkname, grepprg, grepfmt)
  set lazyredraw
  " Close any existing cwindows.
  cclose
  let l:grepformat_save = &grepformat
  let l:grepprogram_save = &grepprg
  set grepformat&vim
  set grepformat&vim
  let &grepformat = a:grepfmt
  let &grepprg = a:grepprg
  if &readonly == 0 | update | endif
  silent! grep! %
  let &grepformat = l:grepformat_save
  let &grepprg = l:grepprogram_save
  let l:mod_total = 0
  let l:win_count = 1
  " Determine correct window height
  windo let l:win_count = l:win_count + 1
  if l:win_count <= 2 | let l:win_count = 4 | endif
  windo let l:mod_total = l:mod_total + winheight(0)/l:win_count |
        \ execute 'resize +'.l:mod_total
  " Open cwindow
  execute 'belowright copen '.l:mod_total
  nnoremap <buffer> <silent> c :cclose<CR>
  set nolazyredraw
  redraw!
  let tlist=getqflist() ", 'get(v:val, ''bufnr'')')
  if empty(tlist)
      if !hlexists('GreenBar')
          hi GreenBar term=reverse ctermfg=white ctermbg=darkgreen guifg=white guibg=darkgreen
      endif
      echohl GreenBar
      echomsg a:checkname . " correct"
      echohl None
      cclose
  endif
endfunction

function! Pep8()
    call <SID>Pygrep('pep8','pep8 --repeat','%f:%l:%m')
endfunction

function! Pep257()
    call <SID>Pygrep('pep257','pep257','%f:%l:%m')
endfunction

function! Pylint()
    call <SID>Pygrep('pylint','pylint --msg-template "{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" --reports=n','%f:%l:%m')
endfunction

function! Flake8()
    call <SID>Pygrep('flake8','flake8 --max-line-length 119','%f:%l:%c: %m')
endfunction

:nnoremap <Leader>pl :call Pylint()<CR><CR>
:nnoremap <Leader>p8 :call Pep8()<CR><CR>
:nnoremap <Leader>pf :call Flake8()<CR><CR>
:nnoremap <Leader>p7 :call Pep257()<CR><CR>
:nnoremap <Leader>pt :MakeGreen %<CR>:copen<CR>
