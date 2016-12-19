function! b#sneak#(pattern, reverse, mode)
  if a:mode =~# "^[vV\<C-v>]"
    execute 'normal!' (v:count > 0 ? v:count : '').'gv'
  endif
  if v:count > 0
    execute 'normal!' v:count.(a:reverse == 0 ? 'L' : 'H')
    return
  endif
  " Disable "syntax" 'foldmethod' because `syntax clear` would open folds
  if &foldmethod[0] == 's'
    let [fdm, &foldmethod] = [&foldmethod, 'manual']
  endif
  let c = v#getchar()
  if empty(c) |return |endif
  if empty(a:pattern)
    if c =~# '\v^(\d|\a)$' " to match a boundary
      let p = c =~# '\d' ? '\d' : (c =~# '\l' ? '\l' : '\u')
      let pattern = '\v'.p.'@<!'.c.'|'.c.p.'@!'
    elseif c == "\<BS>" " get a new character, to match a non-boundary
      let c = v#getchar()
      let p = c =~# '\d' ? '\d' : (c =~# '\l' ? '\l' : '\u')
      let pattern = '\v'.p.'\zs'.c.'\ze'.p
    elseif c == "\<CR>" " to match the first non-blank character of a line
      let pattern = '\_^\s*\zs'
    else " to match a literal
      let c = escape(c, '\')
      let pattern = '\V'.c.'\@<!'.c.'\|'.c.c.'\@!'
    endif
  else
    let pattern = substitute(a:pattern, '\CIN', c, 'g')
  endif
  " op, input, inputlen, count, repeatmotion, reverse, inclusive, label
  " inclusive: 2 means inclusive-exclusive motion like /
  call sneak#to(a:mode, '\m'.pattern, 1, 1, 0, a:reverse, 2, 1)
  let g:sneak#oneline = 0
  if exists('l:fdm')
    let &foldmethod = fdm
  endif
endfunction

function! b#sneak#repeat(op, reverse) abort " adjusted from sneak#rpt()
  let st = sneak#state()
  if st.rst
    execute 'normal!' (a:op =~? "[v\<C-v>]" ? 'gv' : '').v:count1.(a:reverse ?
          \ !exists('*getcharsearch') || getcharsearch().forward ? ',' : ';' :
          \ !exists('*getcharsearch') || getcharsearch().forward ? ';' : ',')
  else
    call sneak#to(a:op, st.input, st.inputlen, v:count1, 1, a:reverse, st.inclusive, 0)
  endif
endfunction
