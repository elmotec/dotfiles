"VIM ressource file
" vim: set encoding=utf-8

" For debugging purpose if needed.
" set verbose=9

" Use Vim settings, rather then Vi settings.
" This must be first, because it changes other options as a side effect.
set nocompatible

" Uses pathogen to set up vim extensions in vimfiles/bundles.
call pathogen#infect()
call pathogen#helptags()

" Auto-source .vimrc when it is saved.
autocmd! bufwritepost .vimrc source %

" Adds vimfiles to the runtimepath (not by default for unix).
set runtimepath+=~/vimfiles

" No need for backup.
set nobackup
" ... or swap file.
set noswapfile

" Change tabulation to 4 spaces
set tabstop=4

" shifts 4 spaces at a time
set shiftwidth=4

" Causes tab at the begining of a line (only !) to insert spaces
set smarttab
set expandtab

" Auto indent program in a C-like fashion
set autoindent

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if has("gui_running")
  noremap <c-Down> <c-w>j
  noremap <c-Up> <c-w>k
  noremap <c-Right> <c-w>l
  noremap <c-Left> <c-w>h
else
  set term=builtin_ansi
endif

" Sets file encodings to UTF-8.
set fileencodings=utf-8

" Sets visual bell instead of the beep
set vb

" Instead of failing a command because of unsaved changes,
" raise a dialogue asking if you wish to save changed files.
set confirm

" List the path where to look for files
set path=.,${HOME}/etc,${HOME}/cpp/libs/**,${HOME}/scripts

" Set the characters acceptable as part of a file name
" Needed for /home/lecomtj/myfile as { and } aren't built in
set isfname=@,48-57,/,.,-,_,+,,,$,~,{,}

" Always display line and column
set ruler

" Show status line of last command
set laststatus=2

" Hilight matching parenthesis
set showmatch

" Shows line number in the margin
set number

" Repeat last command and put cursor at the start of the changes
nmap . .`[

" Scrolls while keeping the cursor in the middle of the screen.
noremap <c-j> jzz
noremap <c-k> kzz

"(*) There is a default policy is $VIM is not defined
" please, refer to Vim documentation (www.vim.org)

" Sets the shell to use (bash inherit variable in the
" shell that started vim)
"set shell=/bin/bash

" Sets the location of tag files
set tag=tags,./tags,../tags,../../tags,../../../tags,../../../../tags

" Sets the font for windows.
if has("gui_win32")
    set guifont=Source\ Code\ Pro:12
elseif has("gui")
    set guifont=Source\ Code\ Pro\ 12
endif

" Sets the colors to desert style.
color lucius

" Turns syntax hiligting on and associate s to toggle hilight on/off.
syntax on

" Mimics Visual Studio interface.
" Moves around between buffers with Ctrl+Tab and Ctrl+Shift+Tab.
noremap <c-Tab> :bn<CR>
noremap <c-s-Tab> :bp<CR>
" Control S saves current file.
noremap <c-S> :w<CR>
" Control-F4 closes the buffer.
noremap <c-F4> :bd<CR>

" Train myself to not use arrow keys
noremap <Up> <NOP>
noremap <Right> <NOP>
noremap <Left> <NOP>
noremap <Down> <NOP>

" Leaves leader as the default \
" let mapleader = "\"
" Hilight search
" wrap/unwrap lines
nmap <Leader>w :set wrap!<CR>
" Show line numbers (absolute)
nmap <Leader>n :set number!<CR>
" Show line numbers (relative)
nmap <Leader>r :set relativenumber!<CR>
" Show task list (FIXME, TODO, ...). Requires TaskList.vim plugin.
nmap <Leader>l <Plug>TaskList
" Show cursor line
nmap <Leader>c :set cursorline!<CR>
set cursorline
" Lists all buffers.
nmap <Leader>b :ls<CR>
" Hilights searched terms on/off.
nmap <Leader>s :set hlsearch!<CR>
" Starts file explorer.
nmap <Leader>e :Ex<CR>
" Tag list explorer
nmap <Leader>t :TlistToggle<CR>
" Loops through tags instead of sticking to the first one.
nmap <c-T> <c-T><z><z>

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  filetype on
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " Auto load python specific extensions (bring in
  " $VIMRUNTIME/ftplugin/python* files and directories).
  autocmd BufNewFile,BufRead *.py set filetype=python

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
endif " has("autocmd")

" Enhanced file choices.
set wildmenu
set wildignore+=*.pyc,*.o,*.obj,.svn,CVS,.git,NTUSER*

" UltiSnips customization to use <tab> to trigger jumps.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
