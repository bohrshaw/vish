function! grep#grep(prg, cmd)
  if a:prg == 'ag'
    if a:cmd =~# '^\w\+\s\+-g\s'
      let grepprg = 'ag --nocolor'
      let grepformat = "%f"
    else
      let grepprg = 'ag --nocolor --column'
      let grepformat = '%f:%l:%c:%m'
    endif
  elseif a:prg == 'ack'
    if a:cmd =~# '^\w\+\s\+-g\s'
      let grepprg = 'ack --nocolor'
      let grepformat = "%f"
    else
      let grepprg = 'ack --nocolor --nobreak --column'
      let grepformat = '%f:%l:%c:%m'
    endif
  endif
  let grepformat_bak=&grepformat
  try
    let &l:grepprg=grepprg
    let &grepformat=grepformat
    execute escape(a:cmd, '%#|')
  finally
    setlocal grepprg=
    let &grepformat=grepformat_bak
  endtry
endfunction
