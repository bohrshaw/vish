function! cmd#expand()
  let cmd = getcmdline()
  let [range, abbr] = [matchstr(cmd, '^\A*'), matchstr(cmd, '\a.*')]
  let parts = map(split(abbr, abbr =~ '\s' ? '\s' : '\zs'), 'toupper(v:val[0]).v:val[1:]')
  return range . join(parts, '*')
endfunction

function! cmd#bang()
  let [cmd, args] = split(getcmdline(), '\v(^\a+)@<=\ze(\A|$)', 1)
  return cmd.'!'.args
endfunction

function! cmd#link_targets()
  let [cmd; links] = split(getcmdline())
  for l in links
    let cmd .= ' '.fnamemodify(resolve(expand(l)), ':~:.')
  endfor
  return cmd
endfunction
