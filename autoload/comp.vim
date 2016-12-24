" Trigger user-completion without changing 'completefunc'.
function! comp#user(cfu)
  let s:completefuc = &completefunc
  let &completefunc = a:cfu
  augroup complete_user | autocmd!
    autocmd TextChangedI * let &completefunc = s:completefuc |
          \ autocmd! complete_user
  augroup END
  return "\<C-x>\<C-u>"
endfunction

" Return matching shell commands
function! comp#shellcmd(findstart, base)
  if a:findstart " locate the start of the word
    return match(getline('.'), '[[:alnum:]._-]*\%'.col('.').'c')
  else " find commands matching "a:base"
    return getcompletion(a:base, 'shellcmd')
  endif
endfunction
