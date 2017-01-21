function! term#shell(str, ...)
  " These terminal names end with text matching ';\d'. Why a ';'? Because it's
  " easy to type `:b;1` to switch to it.
  " And in practice, I seldom use more than 3 terminals. Thus numbers after 3
  " may be used for speciall purpose in the future.
  if a:str !~ '^\d'
    let [name, cmd] =  ['1', a:str]
  else
    let sep = match(a:str, ' \|$') " assume a single space
    let [name, cmd] =  [strpart(a:str, 0, sep), strpart(a:str, sep+1)]
    if name[0] == '9' " change the directory
      let cmd = 'pushd '.(exists('b:git_dir') ? b:git_dir[:-6] : expand('%:p:h'))."\<CR>".cmd
      let name = name == '9' ? '1' : name[1:]
    endif
  endif
  let bufname = 'term://*;#;'.name
  let bufwin = bufwinnr(bufname)
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
    call feedkeys(cmd =~ "\<CR>$" ? cmd : cmd."\<CR>")
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
