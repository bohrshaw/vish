function! map#global(mode)
  let lhs = ''
  while 1
    let c = v#getchar()
    if empty(c)
      return
    endif
    let lhs .= c
    let map = maparg(lhs, a:mode, 0, 1)
    if empty(map)
      continue
    endif
    try " the matched mapping may not be local
      execute a:mode.'unmap <buffer>' lhs
    catch
      Echow 'No such local mapping.' | return 1
    endtry
    execute 'normal' (a:mode == 'x' ? 'gv' : '').lhs
    execute a:mode.(map.noremap ? 'noremap' : 'map')
          \ map.silent ? '<silent>' : ''
          \ map.expr ? '<expr>' : ''
          \ map.nowait ? '<nowait>' : ''
          \ '<buffer>' map.lhs map.rhs
    return
  endwhile
endfunction
