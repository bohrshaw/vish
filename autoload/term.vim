function! term#shell(str, ...)
  " These terminal names end with text matching ';\d'. Why a ';'? Because it's
  " easy to type `:b;1` to switch to it.
  " And in practice, I seldom use more than 3 terminals. Thus numbers after 3
  " may be used for speciall purpose in the future.
  if a:str =~ '^;'
    let sep = match(a:str, ' ')
  endif
  let [name, cmd] = exists('l:sep') ?
        \ [strpart(a:str, 0, sep), strpart(a:str, sep+1)] :
        \ [';1', a:str]
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

function! term#send(type, ...)
  let tname = len(a:type) > 1 ?
        \ (v:prevcount == 0 ? 1 : v:prevcount) : v:count1
  let [wise, mode] =
        \ a:type ==# 'line' ? ["'", '[]'] :
        \ a:type ==# 'char' ? ["`", '[]'] :
        \ a:type ==# 'V' ? ["'", '<>'] :
        \ a:type ==# 'v' ? ["`", '<>'] : ['', '']
  execute 'normal! '.wise.mode[0].'"zy'.(wise == '`' ? 'v' : '').wise.mode[1]
  call term#shell(';'.tname.' '.@z, 'split')
  call feedkeys("\<C-\>\<C-n>\<C-w>p")
endfunction
