function! macro#recur()
  let r = v#getchar() | if empty(r) | return | endif
  execute 'normal! q'.r.'q'
  " Setup a temporary mapping to terminate and execute the macro
  execute printf("nnoremap q q:call setreg('%s', '@%s', 'a')<Bar>".
        \"try<Bar>execute 'normal @%s'<Bar>".
        \"finally<Bar>execute 'nunmap q'<Bar>endtry<CR>", r, r, r)
  execute 'normal! q'.r
endfunction

function! macro#repeat(...)
  let r = v#getchar() | if empty(r) | return | endif
  let [start, end] = a:0 ? [getpos("'["), getpos("']")] :
        \ [getpos("'<"), getpos("'>")]
  let [line, col] = getpos('.')[1:2]
  while line >= start[1] && line <= end[1] &&
        \ col >= start[2] && col <= end[2]
    execute 'normal @'.r
    let [line, col] = getpos('.')[1:2]
  endwhile
endfunction

function! macro#line(...) range
  let r = v#getchar() | if empty(r) | return | endif
  execute (a:0 ? "'[,']" : a:firstline.','.a:lastline).'normal! @'.r
endfunction
