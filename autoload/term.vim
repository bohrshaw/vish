function! term#shell(name)
  let [name, cmd] = a:name =~ '^;' ?
        \ [matchstr(a:name, ';\S*'), matchstr(a:name, '\s\zs.*')] :
        \ [';1', a:name]
  let bufname = 'term://*;#'.name
  let bufwin = bufwinnr(bufname)
  if bufwin > 0
    execute bufwin.'wincmd w'
  else
    " Can't easily test if the buffer is listed.
    try
      execute 'keepjumps buffer '.bufname
    catch
      keepjumps enew
      keepjumps call termopen(matchstr(&shell, '\a*$').';#'.name)
      startinsert
    endtry
  endif
  if !empty(cmd)
    call feedkeys(cmd."\<CR>")
  endif
endfunction
