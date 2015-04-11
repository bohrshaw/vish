" Utilities and helpers

" a wapper around getchar()
function! v#getchar(...)
  echon '>'
  let cs = ''
  for i in range(1, get(a:, 1, 1))
    let c = getchar()
    let c = type(c) == type(0) ? nr2char(c) : c
    if index(["\<esc>", "\<c-c>"], c) >= 0
      break
    endif
    let cs .= c
  endfor
  return cs
endfunction

" a list of listed buffer numbers
function! v#bufnrs()
  redir => bufs
  silent ls
  redir END
  return map(split(bufs, '\n'), 'matchstr(v:val, ''\d\+'')')
endfunction

" a list of listed buffer names
function! v#bufnames()
  return map(v#bufnrs(), 'bufname(v:val+0)')
endfunction
