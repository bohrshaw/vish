" Grep using 'ag' or 'ack'
function! grep#grep(prg, cmd)
  if a:prg == 'ag'
    if a:cmd =~# '^\w\+\s\+-g\s'
      let grepprg = 'ag --nocolor'
      let grepformat = "%f"
    else
      let grepprg = 'ag --column'
      let grepformat = '%f:%l:%c:%m'
    endif
  elseif a:prg == 'ack'
    if a:cmd =~# '^\w\+\s\+-g\s'
      let grepprg = 'ack --nocolor'
      let grepformat = "%f"
    else
      let grepprg = 'ack --column'
      let grepformat = '%f:%l:%c:%m'
    endif
  endif
  let grepformat_bak=&grepformat
  try
    let &l:grepprg=grepprg
    let &grepformat=grepformat
    execute escape(a:cmd, '%#')
  finally
    setlocal grepprg=
    let &grepformat=grepformat_bak
  endtry
endfunction

" Grep HELP files for a pattern(multiline supported) through external programs
function! grep#help(cmd)
  let grepprg_bak = &grepprg
  try
    if executable('ag')
      set grepprg=ag\ -UG\ .*\\.txt
    elseif executable('ack')
      set grepprg=ack\ --noenv\ --type-set=txt:ext:txt\ --txt
    else
      execute 'helpgrep '.a:cmd
      return
    endif
    let path = ''
    for entry in split(&rtp, ',')
      let entry_doc = entry.'/doc'
      if isdirectory(entry_doc) && entry !~# '[/\\]after[/\\]\?$'
        let path .= ' '.entry_doc
      endif
    endfor
    execute a:cmd . path
  finally
    let &grepprg = grepprg_bak
  endtry
endfunction
