function! key#case(arg)
  let b:case_reverse = get(b:, 'case_reverse') ? 0 : a:arg
  if !exists('#case_reverse#InsertCharPre#<buffer>')
    augroup case_reverse
      autocmd InsertCharPre <buffer> if b:case_reverse|
            \ let v:char = v:char =~# '\l' ? toupper(v:char) : tolower(v:char)|
            \ endif|
            \ if b:case_reverse == 1 && v:char !~ '\h'|
            \ let b:case_reverse = 0|
            \ endif
      " Wouldn't be triggered if leaving insert mode with <C-C>
      autocmd InsertLeave <buffer> let b:case_reverse = 0| autocmd! case_reverse
    augroup END
  endif
  return ''
endfunction

function! key#notate()
  let c1 = v#getchar(1, 1)
  if empty(c1)
    return ''
  endif
  if strtrans(c1)[0] == '^'
    let c1_2 = strtrans(c1)[1]
    if c1_2 == 'i'
      return '<Tab>'
    elseif c1_2 == 'm'
      return '<CR>'
    elseif c1_2 == '['
      return '<Esc>'
    else
      return '<C-'.tolower(c1_2).'>'
    endif
  elseif has_key(s:keymap, c1) == 1
    return s:keymap[c1]
  endif
  let c2 = v#getchar(1, 1)
  if empty(c2)
    return ''
  endif
  let c2_ = has_key(s:keymap_sp, c2) ? s:keymap_sp[c2] : c2
  let cc = c1.c2
  if has_key(s:keymap, cc) == 1
    return s:keymap[cc]
  elseif c1 ==? 'f'
    let c2 = c2 == 0 ? 1.v#getchar() : c2
    return '<'.toupper(c1).c2.'>'
  elseif cc =~# 'c.'
    return '<C-'.(c2 =~# '\u' ? 'S-'.tolower(c2_) : c2_).'>'
  elseif cc =~# '[Cx].'
    return 'CTRL-'.toupper(c2)
  elseif cc =~# '[md].'
    return '<'.toupper(c1).'-'.c2_.'>'
  else
    return ''
  endif
endfunction

let s:keymap_sp = {
      \"\<Tab>": 'Tab',
      \' ':      'Space',
      \"\<CR>":  'CR',
      \"\<BS>":  'BS',
      \}

let s:keymap = {
      \' ':      '<Space>',
      \"\<BS>":  '<BS>',
      \"\<Left>":  '<Left>',
      \"\<Right>": '<Right>',
      \"\<Up>":    '<Up>',
      \"\<Down>":  '<Down>',
      \'<':      '<lt>',
      \'\':      '<Bslash>',
      \'|':      '<Bar>',
      \'bu':     '<buffer>',
      \'no':     '<nowait>',
      \'nw':     '<nowait>',
      \'nm':     '<nomodeline>',
      \'si':     '<silent>',
      \'sp':     '<special>',
      \'sc':     '<script>',
      \'ex':     '<expr>',
      \'un':     '<unique>',
      \'L':      '<Leader>',
      \'ll':     '<LocalLeader>',
      \'lL':     '<LocalLeader>',
      \'P':      '<Plug>',
      \'S':      '<SID>',
      \'N':      '<Nop>',
      \'l1':     '<line1>',
      \'l2':     '<line2>',
      \'co':     '<count>',
      \'re':     '<reg>',
      \'ba':     '<bang>',
      \'ar':     '<args>',
      \'qa':     '<q-args>',
      \'fa':     '<f-args>',
      \}
