function! win#max()
  if exists('t:winrestcmd')
    execute t:winrestcmd
    unlet t:winrestcmd
  else
    let t:winrestcmd = winrestcmd()
    resize | vertical resize
    cal winrestcmd()
  endif
endfunction
