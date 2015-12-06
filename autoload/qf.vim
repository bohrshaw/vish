function! qf#window()
  nnoremap <buffer><nowait><CR> <CR>
  nnoremap <buffer>q <C-W>c
  nnoremap <buffer><C-w>v <C-W><CR><C-W>H
  nnoremap <buffer><C-w><C-t> <C-W><CR><C-W>T

  setlocal statusline=%1*%t
        \%*%{qf#title().w:qf_ptn}%1*%{w:qf_prg}
        \%*%=%11.(%c:%l/%L:%P%)
  let b:did_ftplugin = 1 " override $VIMRUNTIME/ftplugin/qf.vim

  setlocal nocursorline
endfunction

function! qf#title()
  if exists('w:quickfix_title')
    let i = match(w:quickfix_title, '\s\zs[^-]')
    let j = match(w:quickfix_title, '\v\ze%(/dev/null|NUL)') - i - 1
    let w:qf_ptn = strpart(w:quickfix_title , i , j >= 0 && j < 50 ? j : 50)
    let w:qf_prg = strpart(w:quickfix_title , 0 , i-1)
  else
    let [w:qf_ptn, w:qf_prg] = ['', '']
  endif
  return ''
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
