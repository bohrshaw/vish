function! term#shell(name, ...)
  let [name, cmd] = a:name =~ '^;' ?
        \ [matchstr(a:name, ';\S*'), matchstr(a:name, '\s\zs.*')] :
        \ [';1', a:name]
  let bufname = 'term://*;#'.name
  let bufwin = bufwinnr(bufname)
  if bufwin > 0
    execute bufwin.'wincmd w'
  else
    if a:0 | split _ | endif
    " Can't easily test if the buffer is listed.
    try
      execute 'keepjumps buffer '.bufname
    catch
      keepjumps enew
      keepjumps call termopen(matchstr(&shell, '\a*$').';#'.name)
    endtry
  endif
  startinsert
  if !empty(cmd)
    call feedkeys(cmd =~ "\n$" ? cmd : cmd."\<CR>")
  endif
endfunction

function! term#send(type)
    let [wise, mode] =
          \ a:type ==# 'line' ? ["'", '[]'] :
          \ a:type ==# 'char' ? ["`", '[]'] :
          \ a:type ==# 'V' ? ["'", '<>'] :
          \ a:type ==# 'v' ? ["`", '<>'] : ['', '']
    execute 'normal! '.wise.mode[0].'"zy'.(wise == '`' ? 'v' : '').wise.mode[1]
  call term#shell(@z, 'split')
  call feedkeys("\<C-\>\<C-n>\<C-w>p")
endfunction
