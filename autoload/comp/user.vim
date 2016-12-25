" This file contains various 'completefunc' functions.
" Use comp#user() to not change 'completefunc'.

function! comp#user#shellcmd(findstart, base)
  if a:findstart " locate the start of the word
    return match(getline('.'), '[[:alnum:]._-]*\%'.col('.').'c')
  else " find commands matching "a:base"
    return getcompletion(a:base, 'shellcmd')
  endif
endfunction
