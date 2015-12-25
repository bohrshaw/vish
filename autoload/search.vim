function! search#star(star, ...)
  let flag = get(a:, 1, '')
  let mode = mode(1)
  let isop = mode[1] == 'o'
  if isop
    autocmd! search_hl
  else
    let delay = 1
    for t in [flag == 's', mode != 'n']
      if t
        let delay += 1
      endif
    endfor
    call search#hl(delay)
  endif
  let slash = a:star =~ '*' ? '/' : '?'
  if mode =~ '^n'
    let echoptn = 'echo '.string(slash).'.@/'
    if flag == 'C'
      set noignorecase
      return a:star."/\<Up>\\C\<C-c>".
            \ ':set ignorecase | let @/ .= "\\C" | '.echoptn."\<CR>"
    else
      return (isop ? "\<Esc>" : '').
            \ a:star.'zv:'.echoptn."\<CR>".
            \ (flag == 's' || isop ? 'N' : '').
            \ (isop ? '"'.v:register.v:count1.v:operator.'g'.
            \   (slash == '/' ? 'n' : 'N') : '')
    endif
  else
    return '"zy'.slash.'\C\V'.
          \ (a:star[0] == 'g' ? '\<' : '').
          \ "\<C-r>=escape(@z, '\\')\<CR>".
          \ (a:star[0] == 'g' ? '\m\>' : '').
          \ "\<CR>zv".(flag == 's' ? 'N' : '')
  endif
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
          \   let s:delay -= 1 |
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
" This may break redo; thus don't break silently.
" inoremap <silent><Plug>_nohlsearch <C-\><C-o>:nohlsearch<CR>
