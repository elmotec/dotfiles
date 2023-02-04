function! airline#themes#base16#refresh()
  let g:airline#themes#base16#palette = {}

  "let g:airline#themes#base16#palette.accents = {
  "      \ 'red': airline#themes#get_highlight('Constant'),
  "      \ }

  let s:N1 = airline#themes#get_highlight2(['DiffText', 'bg'], ['DiffText', 'fg'])
  let s:N2 = airline#themes#get_highlight2(['Visual', 'fg'], ['Visual', 'bg'])
  let s:N3 = airline#themes#get_highlight('CursorLine')
  let g:airline#themes#base16#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

  let group = airline#themes#get_highlight('Statement')
  let g:airline#themes#base16#palette.normal_modified = {
        \ 'airline_c': [ group[0], '', group[2], '', '' ]
        \ }

  let s:I1 = airline#themes#get_highlight2(['DiffText', 'bg'], ['DiffAdded', 'fg'])
  let s:I2 = s:N2
  let s:I3 = s:N3
  let g:airline#themes#base16#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
  let g:airline#themes#base16#palette.insert_modified = g:airline#themes#base16#palette.normal_modified

  let s:R1 = airline#themes#get_highlight2(['DiffText', 'bg'], ['WarningMsg', 'fg'])
  let s:R2 = s:N2
  let s:R3 = s:N3
  let g:airline#themes#base16#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)
  let g:airline#themes#base16#palette.replace_modified = g:airline#themes#base16#palette.normal_modified

  let s:V1 = airline#themes#get_highlight2(['DiffText', 'bg'], ['Ignore', 'fg'])
  let s:V2 = s:N2
  let s:V3 = s:N3
  let g:airline#themes#base16#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)
  let g:airline#themes#base16#palette.visual_modified = g:airline#themes#base16#palette.normal_modified

  " Use VertSplit's bg and default fg (reversed) for inactive statusline.
  let s:VS = airline#themes#get_highlight('VertSplit')
  let s:IA = [ s:VS[1], 'NONE', s:VS[2], 'NONE', 'reverse']

  let g:airline#themes#base16#palette.inactive =
        \ airline#themes#generate_color_map(s:IA, s:IA, s:IA, s:IA, s:IA, s:IA)
  let s:IM = [ s:VS[1], 'NONE', s:VS[2], 'NONE', 'reverse']
  let g:airline#themes#base16#palette.inactive_modified =
        \ airline#themes#generate_color_map(s:IM, s:IM, s:IM, s:IM, s:IM, s:IM)

  " Warnings
  let s:WI = airline#themes#get_highlight2(['WarningMsg', 'bg'], ['Search', 'fg'])
  let g:airline#themes#base16#palette.normal.airline_warning = [
       \ s:WI[0], s:WI[1], s:WI[2], s:WI[3]
       \ ]

  let g:airline#themes#base16#palette.normal_modified.airline_warning =
      \ g:airline#themes#base16#palette.normal.airline_warning

  let g:airline#themes#base16#palette.insert.airline_warning =
      \ g:airline#themes#base16#palette.normal.airline_warning

  let g:airline#themes#base16#palette.insert_modified.airline_warning =
      \ g:airline#themes#base16#palette.normal.airline_warning

  let g:airline#themes#base16#palette.visual.airline_warning =
      \ g:airline#themes#base16#palette.normal.airline_warning

  let g:airline#themes#base16#palette.visual_modified.airline_warning =
      \ g:airline#themes#base16#palette.normal.airline_warning

  let g:airline#themes#base16#palette.replace.airline_warning =
      \ g:airline#themes#base16#palette.normal.airline_warning

  let g:airline#themes#base16#palette.replace_modified.airline_warning =
      \ g:airline#themes#base16#palette.normal.airline_warning

  " Errors
  let s:ER = airline#themes#get_highlight2(['ErrorMsg', 'bg'], ['ErrorMsg', 'fg'])
  let g:airline#themes#base16#palette.normal.airline_error = [
       \ s:ER[0], s:ER[1], s:ER[2], s:ER[3]
       \ ]

  let g:airline#themes#base16#palette.normal_modified.airline_error =
      \ g:airline#themes#base16#palette.normal.airline_error

  let g:airline#themes#base16#palette.insert.airline_error =
      \ g:airline#themes#base16#palette.normal.airline_error

  let g:airline#themes#base16#palette.insert_modified.airline_error =
      \ g:airline#themes#base16#palette.normal.airline_error

  let g:airline#themes#base16#palette.visual.airline_error =
      \ g:airline#themes#base16#palette.normal.airline_error

  let g:airline#themes#base16#palette.visual_modified.airline_error =
      \ g:airline#themes#base16#palette.normal.airline_error

  let g:airline#themes#base16#palette.replace.airline_error =
      \ g:airline#themes#base16#palette.normal.airline_error

  let g:airline#themes#base16#palette.replace_modified.airline_error =
      \ g:airline#themes#base16#palette.normal.airline_error

endfunction
call airline#themes#base16#refresh()
