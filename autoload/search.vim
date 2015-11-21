" Temporarily turn on search highlighting
" An alternative implementation:
"   $MYVIM/bundle/incsearch.vim/autoload/incsearch/autocmd.vim
function! search#hl(...)
  if get(g:, 'hlsearch') | return '' | endif
  let s:delay = get(a:, 1)
  augroup search_hl
    autocmd!
    " Direct :nohlsearch doesn't work, :help autocmd-searchpat
    autocmd CursorMoved *
          \ if s:delay |
          \   let s:delay = 0 |
          \ else |
          \   call feedkeys("\<C-\>\<C-n>\<Plug>_nohlsearch") |
          \   execute 'autocmd! search_hl' |
          \ endif
  augroup END
  return ''
endfunction
nnoremap <silent><Plug>_nohlsearch :nohlsearch<CR>
