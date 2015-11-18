" Get a list of buffers
" If argument 1 is empty, listed buffers are displayed.
" If argument 1 is "!", both listed and non-listed buffers are displayed.
" If argument 1 is "?", non-listed buffers are displayed.
function! buf#nrs(...)
  return map(s:ls(get(a:, 1, '')), 'matchstr(v:val, ''\d\+'')')
endfunction
function! buf#names(...)
  return map(buf#nrs(get(a:, 1, '')), 'bufname(v:val+0)')
endfunction
function! s:ls(...)
  let a1 = get(a:, 1, '')
  redir => bufs
  execute 'silent ls'.(empty(a1) ? '' : '!')
  redir END
  let buflist = split(bufs, '\n')
  if a1 == '?'
    return filter(buflist, 'v:val =~# ''\v^\s*\d+u''')
  else
    return buflist
  endif
endfunction

" Wipe out all unlisted buffers
function! buf#wipe_unlisted()
  for b in range(1, bufnr('$'))
    if bufexists(b) && ! buflisted(b)
      exe 'bw' . b
    endif
  endfor
endfunction
