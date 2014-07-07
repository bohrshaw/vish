" Source the current line of Vim scripts
nnoremap <buffer> <silent> <LocalLeader>r mt^"ty$:@t<CR>`t
" Source a visual selection (continued lines joined)
xnoremap <buffer> <silent> <LocalLeader>r mt:<C-U>silent '<,'>y t<Bar>
      \ let @t = substitute(@t, '\n\s*\\', '', 'g')<Bar>@t<CR>`t
" Source the entire file
nnoremap <buffer> <LocalLeader>R :source %<CR>

" Enable omni completion for vim scripts
set omnifunc=syntaxcomplete#Complete

" Indenting
set sw=2 ts=2 sts=2
