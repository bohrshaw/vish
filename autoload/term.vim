function! term#shell(name)
  let name = empty(a:name) ? '1' : a:name
  try
    execute 'buffer term://*;#;'.name
  catch
    enew|call termopen(matchstr(&shell,'\a*$').';#;'.name)|startinsert
  endtry
endfunction
