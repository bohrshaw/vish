function! cmdwin#init()
  if bufloaded('[CommandLine]')
    " Note: Not using :below to be able to return to the previous window when
    " the cmdwin is closed.
    " noautocmd silent sbuffer + \[CommandLine] | resize 2
    noautocmd 2split + [CommandLine] | setlocal nobuflisted
    return
  endif
  noswapfile 2split [CommandLine]
  setlocal filetype=vim nobuflisted buftype=nofile bufhidden=hide
endfunction

function! cmdwin#setup()
  nnoremap <silent><buffer><CR> :call histadd(':', getline('.')) \|
        \ noautocmd hide<CR>:<Up><CR>
  imap <buffer><CR> <C-c><CR>
  nnoremap <silent><buffer><M-q> :noautocmd hide<CR>
endfunction

function! cmdwin#line2win()
  call cmdwin#init()
  call append(line('$'), g:_cmdline)
  call cursor('$', g:_cmdlinepos)
endfunction
