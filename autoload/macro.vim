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
  execute (a:0 ? "'[,']" : "'<,'>").'normal @'.nr2char(getchar())
endfunction

function! macro#line(...) range
  let r = v#getchar() | if empty(r) | return | endif
  execute (a:0 ? "'[,']" : a:firstline.','.a:lastline).'normal! @'.r
endfunction
