" plugin specific to cpp

" clang-format.
nmap <Leader>f :w<CR>:!clang-format -i %<CR>:e<CR>

" Switch between .h and .cpp file (must be in the same directory).
nmap <Leader>^ :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>

