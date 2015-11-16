" Diff with another file
function! diff#with(...)
  let filetype=&ft
  tab sp
  diffthis
  " Diff with the current saved state.
  if a:0 == 0
    vnew | exe "setl bt=nofile bh=wipe nobl ft=" . filetype
    r # | 1del
    " Diff with another file.
  else
    exe "vsp " . a:1
  endif
  diffthis
  wincmd p
endfunction
