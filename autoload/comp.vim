" Complete shell commands
function! comp#shellcmd()
  let line = getline('.')
  let start = match(line, '[[:alnum:]._-]*\%'.col('.').'c') " 0 based
  let base = line[start:col('.')-2]
  call complete(start+1, getcompletion(base, 'shellcmd'))
  return ''
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
