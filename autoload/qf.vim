" Execute a commad for each file in the quickfix/location list
function! qf#fdo(cmd, ...) " {{{1
  let bpre = 0
  for i in a:0 == 0 ? getqflist() : getloclist()
    let b = i.bufnr
    if b != bpre
      execute 'silent buffer' b '|' a:cmd
    endif
    let bpre = b
  endfor
endfunction " }}}1
