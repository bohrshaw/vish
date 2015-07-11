function! V#open(...)
  if has('unix')
    call system("xdg-open ".a:1)
  elseif has('win32')
    call system('"'.a:1.'"')
  elseif has('mac')
    call system('open '.a:1)
  endif
endfunction
