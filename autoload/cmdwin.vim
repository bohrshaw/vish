function! cmdwin#init()
  if bufloaded('[CommandLine]')
    " Note: Split below can reduce screen drawing.
    noautocmd below 2split + [CommandLine] | setlocal nobuflisted
    " noautocmd silent below sbuffer + \[CommandLine] | resize 2
    return
  endif
  noswapfile below 2split [CommandLine]
  setlocal filetype=vim nobuflisted buftype=nofile bufhidden=hide
endfunction

function! cmdwin#setup()
  nnoremap <silent><buffer><CR> :call <SID>execute()<CR>
  imap <buffer><CR> <C-c><CR>
  nnoremap <silent><buffer><M-q> :call <SID>hide()<CR>
endfunction

function! s:hide()
  noautocmd wincmd k
  noautocmd +hide
endfunction

function! s:execute()
  call histadd(':', getline('.'))
  call s:hide()
  " Use feedkeys() to make `@:` work.
  call feedkeys(":\<Up>\<CR>", 't')
endfunction

function! cmdwin#line2win()
  call cmdwin#init()
  call append(line('$'), g:_cmdline)
  call cursor('$', g:_cmdlinepos)
endfunction
