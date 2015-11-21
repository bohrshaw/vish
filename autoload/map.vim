function! map#global(mode)
  let lhs = ''
  while 1
    let c = v#getchar() | if empty(c) | return | endif
    let lhs .= c

    " Note: There's no waiting for a longer mapped key sequence.
    let s:map = maparg(lhs, a:mode, 0, 1)
    if empty(s:map) | continue | endif

    " The matched mapping could be global
    execute 'silent!' a:mode.'unmap <buffer>' lhs

    " Feeded keys are run after this function returns
    call feedkeys((a:mode == 'x' ? 'gv' : '').lhs, 't')

    augroup map_global
      autocmd!
      let s:mode = a:mode
      let s:ut = &updatetime | set updatetime=100
      autocmd CursorHold,CursorHoldI,CursorMoved,CursorMovedI *
            \ execute s:mode.(s:map.noremap ? 'noremap' : 'map')
            \ s:map.silent ? '<silent>' : ''
            \ s:map.expr ? '<expr>' : ''
            \ s:map.nowait ? '<nowait>' : ''
            \ '<buffer>' s:map.lhs s:map.rhs |
            \ let &updatetime = s:ut | autocmd! map_global
    augroup END

    return
  endwhile
endfunction
