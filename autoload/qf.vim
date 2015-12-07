function! qf#window()
  nnoremap <buffer><nowait><CR> <CR>
  nnoremap <buffer>q <C-W>c
  nnoremap <buffer><C-w>v <C-W><CR><C-W>H
  nnoremap <buffer><C-w><C-t> <C-W><CR><C-W>T
  nnoremap <buffer><silent>i :echo w:quickfix_title<CR>

  setlocal statusline=%1*%t%*
        \%<%{qf#title()}
        \%1*:%Y%*
        \%=%c:%l/%L:%P
  let b:did_ftplugin = 1 " override $VIMRUNTIME/ftplugin/qf.vim

  setlocal nocursorline
endfunction

" Tidy w:quickfix_title
function! qf#title()
  if !exists('w:quickfix_title')
    return ''
  endif
  let title = matchstr(w:quickfix_title, '\v\C.{-}\ze%( /dev/null| NUL)?$')
  let len = winwidth(0) - len(line('$'))*2 - 25
  " If title is too long, truncate the left or the right.
  " Note here strpart() serves as the opposite of '%<'.
  return (len(title) <= len || title =~# '\v^.%(git|hub) ') ?
        \ title : strpart(title, 1, len)
endfunction

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
