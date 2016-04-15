function! readline#word(key, ...)
  let f = a:key == "\<Right>" || a:key == "\<Del>" ? 1 : 0
  let d = a:key == "\<Del>" || a:key == "\<BS>" ? 1 : 0
  let pat = !a:0 ?
        \ f ? (d ? '\W*\f+' : '\W*\f+\W*') : '\f+\W*' :
        \ f ? '\s*\S+' : '\S+\s*'
  let cur = '%'.getcmdpos().'c'
  let cmd = getcmdline()
  " For matching multi-bytes characters
  let [isf, &isfname] = [&isfname, '@,48-57,_']
  let str = matchstr(cmd, '\v'.(f ? cur.pat : pat.cur))
  let &isfname = isf
  if str == ''
    let str = matchstr(cmd, '\v'.(f ? cur.'\s+' : '\s+'.cur))
  endif
  if d | let @- = str | endif
  return (wildmenumode() ?  " \<BS>" : '').
        \ repeat(a:key, strchars(str))
endfunction

function! readline#head()
  let @- = getcmdline()[:getcmdpos()-2]
  return "\<C-U>"
endfunction

function! readline#tail()
  let @- = getcmdline()[getcmdpos()-1:]
  return repeat("\<Del>", strchars(@-))
endfunction
