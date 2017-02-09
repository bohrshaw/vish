function! term#shell(name, cmd, ...)
  " These terminal names end with text matching ';\d'. Why a ';'? Because it's
  " easy to type `:b;1` to switch to it.
  " And in practice, I seldom use more than 3 terminals. Thus numbers after 3
  " may be used for speciall purpose in the future.
  if a:cmd[0] != ';' " the terminal name is digits
    let [name, cmd] =  [a:name, a:cmd]
    if name[0] == '9' " change the directory
      let cmd = 'pushd '.(exists('b:git_dir') ? b:git_dir[:-6] : expand('%:p:h'))."\n".cmd
      let name = name == '9' ? '1' : name[1:]
    endif
  else " the terminal name could be arbitrary
    let sep = match(a:cmd, ' \|$') " assume a single space
    let [name, cmd] =  [strpart(a:cmd, 1, sep), strpart(a:cmd, sep+1)]
  endif
  let bufname = 'term://.*;#;'.name
  let bufwin = v#bufwinnr(bufname, a:0 ? 1 : 0)
  if bufwin > 0
    execute bufwin.'wincmd w'
  else
    if a:0 | split _ | endif
    " Can't easily test if the buffer is listed.
    try
      execute 'keepjumps silent buffer '.bufname
    catch
      keepjumps enew
      keepjumps call termopen(matchstr(&shell, '\a*$').';#;'.name)
    endtry
  endif
  startinsert
  if !empty(cmd)
    call feedkeys(cmd =~ "\n$" ? cmd : cmd."\n", 'n')
  endif
endfunction

function! term#send(type, ...)
  " Note: v:count would change after a `:normal` command below.
  if v:count + v:prevcount == 0
    let name = '*'
  else
    let name = len(a:type) > 1 ?
          \ (v:prevcount == 0 ? 1 : v:prevcount) : v:count1
  endif
  let [wise, mode] =
        \ a:type ==# 'line' ? ["'", '[]'] :
        \ a:type ==# 'char' ? ["`", '[]'] :
        \ a:type ==# 'V' ? ["'", '<>'] :
        \ a:type ==# 'v' ? ["`", '<>'] : ['', '']
  execute 'normal! '.wise.mode[0].'"zy'.(wise == '`' ? 'v' : '').wise.mode[1]
  call term#shell(name, @z, 'send')
  call feedkeys("\<C-\>\<C-n>\<C-w>p")
endfunction
