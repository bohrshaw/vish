function! grep#grep(prg, cmd)
  let grepprg_bak = &l:grepprg
  let &l:grepprg = a:prg == 'grep' ? g:greps.grep :
        \ a:prg == 'ag' ? g:greps.ag :
        \ a:prg == 'pt' ? g:greps.pt :
        \ a:prg == 'ack' ? g:greps.ack :
        \ &grepprg

  try
    execute 'silent' escape(a:cmd[0] == '=' ? a:cmd[1:] : 'grep '.a:cmd, '%#')
  finally
    let &l:grepprg = grepprg_bak
  endtry
endfunction

function! grep#help(cmd)
  let grepprg_bak = &grepprg
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
    let &grepprg = grepprg_bak
  endtry
endfunction
