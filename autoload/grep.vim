function! grep#grep(prg, cmd)
  let grepprg = &l:grepprg " local 'grepprg' will be used if not empty
  " Note: expand() converts '/' to '\' on Windows.
  let &l:grepprg =
        \ a:prg == 'git' ? 'git --git-dir='.expand(get(b:, 'git_dir', '.')).' grep -nI' :
        \ a:prg == 'grep' ? g:greps.grep :
        \ a:prg == 'ag' ? g:greps.ag :
        \ a:prg == 'pt' ? g:greps.pt :
        \ a:prg == 'ack' ? g:greps.ack :
        \ &l:grepprg

  try
    execute 'silent' escape(a:cmd[0] == '=' ? a:cmd[1:] : 'grep '.a:cmd, '%#')
  finally
    let &l:grepprg = grepprg
  endtry
endfunction

function! grep#help(cmd)
  let grepprg = &grepprg
  if executable('ag')
    let &grepprg = "ag -UG '.*\.txt'"
  elseif executable('pt')
    let &grepprg = "pt -UG '.*\.txt'"
  elseif executable('ack')
    let &grepprg = "ack --noenv --type-set=txt:ext:txt --txt"
  else
    execute 'helpgrep '.matchstr(a:cmd, '\v\s+\zs.*')
    return
  endif

  let path = ''
  for entry in split(&rtp, ',')
    let entry_doc = entry.'/doc'
    if isdirectory(entry_doc) && entry !~# '[/\\]after[/\\]\?$'
      let path .= ' '.entry_doc
    endif
  endfor
  try
    execute 'silent' a:cmd path
  finally
    let &grepprg = grepprg
  endtry
endfunction
