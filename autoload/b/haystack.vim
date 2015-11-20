function! b#haystack#(items, str, limit, mmode, ispath, crfile, regex) abort
  let items = copy(a:items)
  if a:ispath
    call filter(items, 'v:val !=# a:crfile')
  endif
  return haystack#filter(items, a:str)
endfunction
