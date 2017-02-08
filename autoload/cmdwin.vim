function! cmdwin#init()
  if bufloaded(':Command:Line:')
    if winbufnr(winnr()) == s:bufnr
    elseif winbufnr(winnr() + 1) == s:bufnr
      noautocmd wincmd w
    else
      " Note: Split below can reduce screen drawing.
      noautocmd below 2split + :Command:Line: | setlocal nobuflisted
      " noautocmd silent below sbuffer + :Command:Line: | resize 2
    endif
    return
  endif
  noswapfile below 2split :Command:Line:
  let s:bufnr = bufnr('')
  call cmdwin#setup()
endfunction

function! cmdwin#setup()
  setlocal filetype=vim nobuflisted buftype=nofile bufhidden=hide
  nnoremap <silent><buffer><CR> :call <SID>execute()<CR>
  imap <buffer><CR> <C-c><CR>
  nnoremap <silent><buffer><M-q> :call <SID>hide()<CR>
  nnoremap <buffer><M-e> :call <SID>win2line1()<CR>:<C-\>e<SID>win2line2()<CR>
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

function! s:win2line1()
  let s:cmdline = getline('.')
  let s:cmdpos = col('.')
  call s:hide()
  redraw
endfunction
function! s:win2line2()
  call setcmdpos(s:cmdpos)
  return s:cmdline
endfunction
