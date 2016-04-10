" IME(Input Method Editor) integration
"
" Auto-toggle Fcitx state when leaving/entering Insert Mode.
" This is handled by :python to communicate with a Fcitx FIFO file.
" An alternative method is calling system('fcitx-remote'), which is slow.

if !has('win32') && exists('$DISPLAY') && !exists('$SSH_TTY')
  let g:_fcitx_sock = glob('/tmp/fcitx-socket-*')
  if empty(g:_fcitx_sock) && filewritable($FCITX_SOCKET)
    let g:_fcitx_sock = $FCITX_SOCKET
  endif
endif

if empty(get(g:, '_fcitx_sock', '')) || getftype(g:_fcitx_sock) != 'fifo'
  Echow 'Not available as Fcitx socket is not found.'
  finish
endif

python3 import fcitx
" python3 import importlib; importlib.reload(fcitx)

" The efficiency is about 1ms. And I may still want to disable this.
function! ime#auto(...)
  if !exists('s:ime_auto') || get(a:, 1)
    augroup ime | autocmd!
      autocmd InsertLeave * let b:fcitx_cn =
            \ py3eval('fcitx.toggle() == 2 and fcitx.toggle("c")') ? 1 : 0
      autocmd InsertEnter * execute get(b:, 'fcitx_cn') ?
            \ "python3 fcitx.toggle('o')" : ''
    augroup END
    let s:ime_auto = 1
    if !a:0
      echo 'IME: auto-switch is on.'
    endif
  else
    autocmd! ime
    unlet s:ime_auto
    if !a:0
      echo 'IME: auto-switch is off.'
    endif
  endif
endfunction
