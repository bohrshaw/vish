" Note: Pay attention to when to invoke search#hl()
function! search#star(star, ...)
  let slash = a:star =~ '*' ? '/' : '?'
  if mode() == 'n'
    call search#hl()
    let echoptn = 'echo '.string(slash).'.@/'
    if a:0 " match case
      set noignorecase
      return a:star."/\<Up>\\C\<C-c>".
            \ ':set ignorecase | let @/ .= "\\C" | '.echoptn."\<CR>"
    else
      return a:star.'zv:'.echoptn."\<CR>"
    endif
  else
    " Search literally (case sensitively)
    " Note: Keys to search with word boundary is swapped to be practical.
    return '"zy'.slash.'\C\V'.
          \ (a:star[0] == 'g' ? '\<' : '').
          \ "\<C-r>=".(a:0 ? '' : 'search#hl().')."escape(@z, '\\')\<CR>".
          \ (a:star[0] == 'g' ? '\m\>' : '').
          \ "\<CR>zv"
  endif
endfunction

function! search#cgn()
  let c = v#getchar()
  if c == 'g'
    let c .= v#getchar()
  endif
  if c !~ '[*#]'
    return ''
  endif
  return (mode() == 'n' ? c : search#star(c, -1)).
        \ 'Ncg'.(c =~ '*' ? 'n' : 'N')
endfunction

" Temporarily turn on search highlighting
" An alternative implementation:
"   $MYVIM/bundle/incsearch.vim/autoload/incsearch/autocmd.vim
function! search#hl(...)
  let s:delay = get(a:, 1, 1)
  if get(g:, 'hlsearch') || s:delay < 0
    return ''
  endif
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
