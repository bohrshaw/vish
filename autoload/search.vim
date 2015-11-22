" Temporarily turn on search highlighting
" An alternative implementation:
"   $MYVIM/bundle/incsearch.vim/autoload/incsearch/autocmd.vim
function! search#hl(...)
  if get(g:, 'hlsearch') | return '' | endif
  let s:delay = get(a:, 1, 1)
  augroup search_hl
    autocmd!
    " Direct :nohlsearch doesn't work. (:help autocmd-searchpat)
    " Note: Be considerate with the current state(CursorMoved) and mode.
    autocmd CursorMoved *
          \ if s:delay |
          \   let s:delay = 0 |
          \ else |
          \   call feedkeys("\<Plug>_nohlsearch") |
          \   execute 'autocmd! search_hl' |
          \ endif
  augroup END
  return ''
endfunction
nnoremap <silent><Plug>_nohlsearch :<C-u>nohlsearch<CR>
xnoremap <silent><Plug>_nohlsearch :<C-u>nohlsearch<CR>gv
snoremap <silent><Plug>_nohlsearch <Esc>:nohlsearch<CR>gv<C-g>
