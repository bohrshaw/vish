function! term#shell(name)
  let name = empty(a:name) ? '1' : a:name
  try
    execute 'keepjumps buffer term://*;#;'.name
  catch
    keepjumps enew
    keepjumps call termopen(matchstr(&shell, '\a*$').';#;'.name)
    startinsert
  endtry
endfunction
