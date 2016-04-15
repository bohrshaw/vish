function! readline#word(key, ...)
  let fwd = a:key == "\<Right>" || a:key == "\<Del>" ? 1 : 0
  let del = a:key == "\<Del>" || a:key == "\<BS>" ? 1 : 0
  let word = !a:0 ?
        \ fwd ? (del ? '\W*\f+' : '\W*\f+\W*') : '\f+\W*' :
        \ fwd ? '\s*\S+' : '\S+\s*'
  let cur = '%'.getcmdpos().'c'
  " For matching multi-bytes characters
  let [isf, &isfname] = [&isfname, '@,48-57,_']
  for p in [word, '\s+']
    let str = matchstr(getcmdline(), '\v'.(fwd ? cur.p : p.cur))
    if str != '' | break | endif
  endfor
  let &isfname = isf
  if del | let @- = str | endif
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
