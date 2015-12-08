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
  let grepprg = &l:grepprg
  if executable('ag')
    let &l:grepprg = g:greps['ag'].' -G '.shellescape('.*\.txt')
  elseif executable('pt')
    let &l:grepprg = g:greps['pt'].' -G '.shellescape('.*\.txt')
  elseif executable('ack')
    let &l:grepprg = "ack --noenv --type-set=txt:ext:txt --txt"
  else
    execute 'helpgrep '.matchstr(a:cmd, '\v\s+\zs.*')
    return
  endif

  let paths = ''
  for r in split(&rtp, ',')
    let doc = expand(r.'/doc')
    if isdirectory(doc) && r !~# '[/\\]after[/\\]\?$'
      let paths .= ' '.shellescape(doc)
    endif
  endfor
  try
    execute 'silent' a:cmd paths
  finally
    let &l:grepprg = grepprg
  endtry
endfunction
