" Description: Mappable Meta key in terminals
" Author: Bohr Shaw <pubohr@gmail.com>

" http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim

if has('gui_running')
  finish
endif

let s:key_idx = 0
function! s:bind(c)
  let key_mapped = '<M-'.a:c.'>'
  if a:c =~# '\u'
    let key = key_mapped
  else
    if a:c ==# 'f'
      let key = '<S-Right>'
    elseif a:c ==# 'b'
      let key = '<S-Left>'
    else
      if s:key_idx >= 50
        echohl WarningMsg | echomsg "Out of spare keys!" | echohl None
        return
      endif
      let s:key_idx += 1
      " Unused keys: <[S-]F13>..<[S-]F37>, <[S-]xF1>..<[S-]xF4>
      let key = '<'.(s:key_idx<25 ? '' : 'S-').'F'.(13+s:key_idx%25).'>'
    endif
    " Map the unused key to the mapped key
    execute 'map '.key.' '.key_mapped.'|map! '.key.' '.key_mapped
    " Eliminate even the tiny delay when escaping insert mode
    execute 'inoremap '.key_mapped.' <Esc>'.a:c
  endif
  " Define the key which times out sooner than mapping
  silent! execute 'set '.key."=\<Esc>".a:c
endfunction

" Pre-bind <M-a..z> <M-A..Z>
for i in range(26)
  call s:bind(nr2char(97 + i))
  call s:bind(nr2char(65 + i))
endfor
