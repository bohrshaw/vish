" Description: Mappable Meta key in terminals
" Author: Bohr Shaw <pubohr@gmail.com>

" References:
" https://github.com/tpope/vim-rsi
" http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim

" Issues:
" Even though the tiny key code delay('ttimeoutlen') means that typing
" "<Esc>k" could hardly be recognised as the key code of "<Esc>k" and only
" "<M-k>" can ensure generating this key code, such a key sequence as "<Esc>k"
" in a macro is still recognised as a key code, which is really disruptive to
" macros.
" Another subtle issue is that in normal mode, if "<Esc>" is mapped, "<M-k>"
" is executed as "<Esc>" and then "k", which I suspect a Vim bug.

" Solutions:(Compromise)
" Just like I can use "noremap" to avoid "<Esc>k" to be recognised as a key
" code, I could use "normal! <C-R><C-R>q<CR>" as an alternative to "@q" to
" achieve the same aim, for which I even make a convenient mapping "@!". But
" be aware that ALL keys in that macro are then executed without remapping.
" A probably better way to circumvent this issue is to deliberately use
" "<C-C>" to escape whichever insert, visual or command mode, except that the
" "InsertLeave" autocommand would not be triggered by using "<C-C>".

if has('gui_running')
  finish
endif

" Instead of setting a key code(e.g. "<Esc>k") to key(e.g. "<F13>") and then
" map "<F13>" to a meta-key(e.g. "<M-k>"), I could just set the same key code
" to "<M-k>" directly. But I'm not aware of the potential consequences of
" manipulating meta-key's key codes.
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
      " Unused keys: <[S-]F13>..<[S-]F37>, <[S-]xF1>..<[S-]xF4>
      let key = '<'.(s:key_idx<25 ? '' : 'S-').'F'.(13+s:key_idx%25).'>'
      let s:key_idx += 1
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
for i in map(range(26), 'nr2char(97 + v:val)') +
      \ map(range(26), 'nr2char(65 + v:val)') + ['\', ']']
  call s:bind(i)
endfor
