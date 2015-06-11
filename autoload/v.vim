" Utilities and helpers

" a wapper around getchar()
function! v#getchar(...)
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

" Get a list of buffers
" If argument 1 is empty, listed buffers are displayed.
" If argument 1 is "!", both listed and non-listed buffers are displayed.
" If argument 1 is "?", non-listed buffers are displayed.
function! v#buffers(...)
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
function! v#bufnrs(...)
  return map(v#buffers(get(a:, 1, '')), 'matchstr(v:val, ''\d\+'')')
endfunction
function! v#bufnames(...)
  return map(v#bufnrs(get(a:, 1, '')), 'bufname(v:val+0)')
endfunction

" Create a path (also see the implementation in "vim-eunuch")
function! v#mkdir(...)
  let dir = fnamemodify(expand(a:0 || empty(a:1) ? '%:h' : a:1), ':p')
  try
    call mkdir(dir, 'p')
    echo "Succeed in creating directory: " . dir
  catch
    echohl WarningMsg | echo "Fail in creating directory: " . dir | echohl NONE
  endtry
endfunction
