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
  nnoremap <silent><buffer><M-q> :noautocmd wincmd k \| noautocmd +hide<CR>
  nnoremap <silent><buffer><CR> :call histadd(':', getline('.')) \|
        \ noautocmd wincmd k \| noautocmd +hide<CR>:<Up><CR>
  imap <buffer><CR> <C-c><CR>
endfunction

function! cmdwin#line2win()
  call cmdwin#init()
  call append(line('$'), g:_cmdline)
  call cursor('$', g:_cmdlinepos)
endfunction
