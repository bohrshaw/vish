" Complete shell commands
function! comp#shellcmd()
  let start = comp#startcol('[[:alnum:]._-]*')
  let base = getline('.')[start-1:col('.')-2]
  call complete(start, getcompletion(base, 'shellcmd'))
  return ''
endfunction

" Return the start column(1 based) for complete()
function! comp#startcol(pat)
  return match(getline('.'), a:pat.'\%'.col('.').'c') + 1
endfunction

" Trigger user-completion without changing 'completefunc'.
" Example: inoremap <expr><C-x>c comp#user('comp#shellcmd')
function! comp#user(cfu)
  let s:completefuc = &completefunc
  let &completefunc = a:cfu
  augroup complete_user | autocmd!
    autocmd TextChangedI * let &completefunc = s:completefuc |
          \ autocmd! complete_user
  augroup END
  return "\<C-x>\<C-u>"
endfunction
