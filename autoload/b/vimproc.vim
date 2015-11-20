function! b#vimproc#esc(args, ...)
  if has('win32') && !&shellslash " expand %, #, etc. and escape \ and /
    let pat = '\\\@<![%#].*'
    let match = matchstr(a:args, pat)
    return escape(
          \ empty(match) ? a:args :
          \   substitute(a:args, pat, escape(expand(match), '\'), ''),
          \ '\'.get(a:, 1, ''))
  endif
  return a:args
endfunction
