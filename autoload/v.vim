" Complementary helper functions
"
" There is a library of VimL functions: https://github.com/LucHermitte/lh-vim-lib

" a wapper around getchar()
function! v#getchar(...)
  let cs = ''
  for i in range(1, get(a:, 1, 1))
    let c = getchar()
    let c = type(c) == type(0) ? nr2char(c) : c
    if "\<C-c>" == c
      return ''
    endif
    if !exists('a:2')
      if "\<Esc>" == c
        return ''
      endif
      if "\<CR>" == c
        if cs == ''
          return c
        endif
        return cs
      endif
    endif
    let cs .= c
  endfor
  return cs
endfunction

" Set a variable via an expression/function
function! v#setvar(var, val)
  execute 'let' a:var '=' string(a:val)
  return ''
endfunction

" Execute a command via an expression
function! v#execute(cmd)
  execute a:cmd
  return ''
endfunction

" Get the first buffer name in the current window
" Note: `pat` is a regexp instead of a file-pattern used in bufname().
function! v#bufname(pat)
  for w in range(1, winnr('$'))
    let name = bufname(winbufnr(w))
    if name =~# a:pat
      return name
    endif
  endfor
endfunction

" Get the first buffer window number in the current window
function! v#bufwinnr(pat)
  for w in range(1, winnr('$'))
    if bufname(winbufnr(w)) =~# a:pat
      return w
    endif
  endfor
endfunction
