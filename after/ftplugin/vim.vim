" Source the current line of Vim scripts
nnoremap <buffer> <silent> <LocalLeader>r mz^"zy$:@z<CR>`z
" Source a visual selection (continued lines joined)
xnoremap <buffer> <silent> <LocalLeader>r mz:<C-U>silent '<,'>y z<Bar>
      \ let @z = substitute(@z, '\n\s*\\', '', 'g')<Bar>@z<CR>`z
" Source the entire file
nnoremap <buffer> <LocalLeader>R :source %<CR>

" Enable omni completion for vim scripts
set omnifunc=syntaxcomplete#Complete

" Indenting
set sw=2 ts=2 sts=2
