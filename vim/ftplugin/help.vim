" Maps like vimwiki
nnoremap <buffer> <CR> <C-]>
nnoremap <buffer> <BS> <C-T>
" Attention: last search pattern been changed
nnoremap <buffer> o /'\l\{2,\}'<CR>
nnoremap <buffer> O ?'\l\{2,\}'<CR>
nnoremap <buffer> s /\|\zs\S\+\ze\|<CR>
nnoremap <buffer> S ?\|\zs\S\+\ze\|<CR>
nnoremap <buffer> <tab> /\|\zs\S\+\ze\|<CR>
nnoremap <buffer> <s-tab> ?\|\zs\S\+\ze\|<CR>
