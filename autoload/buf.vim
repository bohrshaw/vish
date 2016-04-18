" Edit a buffer if listed, otherwise a file
function! buf#edit(bufile)
  " Note: Don't use bufexists() as `:b foo` would open the buffer `foobar`.
  execute 'silent keepjumps'
        \ s:ecmds[buflisted(expand(a:bufile))][v:count1 - 1] a:bufile
endfunction
let s:ecmds = [['e', 'sp', 'vs', 'tabe'], ['b', 'sb', 'vert sb', 'tab sb']]

" Like :bufdo, but with a pattern matching buffers.
" Unlike :bufdo, the buffers are not focused one by one.
" A pattern 'unlisted' match all unlisted buffers.
" The match is inverse if a third argument is true.
function! buf#do(pat, act, ...)
  let inverse = get(a:, 1)
  for b in range(1, bufnr('$'))
    if !bufexists(b)
      continue
    endif
    let match = bufname(b) =~? a:pat ||
          \ (a:pat ==? 'unlisted' && !buflisted(b))
    if match || (!match && inverse)
      execute a:act b
    endif
  endfor
endfunction

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
