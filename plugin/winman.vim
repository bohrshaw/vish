" File: winman.vim
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: manage vim windows.

" Using effective window management to navigate and remember your current works
" visually. This is ultra helpful when you are working on many files which are
" messed up in many directories.

" Switch/Exchange the current window with the target window(default is the first
" window), which can be specified with a count. This does not change the window
" layout.
nnoremap <c-w><c-e> :call SwitchWindow()<cr>
function! SwitchWindow()
  " set default target window number to v:count1(1 when not given)
  let target_win = v:count1
  let current_buf = winbufnr(0)
  exe "buffer" . winbufnr(target_win)
  exe target_win . "wincmd w"
  exe "buffer" . current_buf
endfunction

" Attach a window(default is the current window) bellow the last windows.
" Thus making a window stack at the right of the screen. Unlike "<c-w>J" which
" make the moved window take the whole width of screen, the moved window has the
" same width with its above window.
" Implementation notes: Append a count before a keystroke may cause mysterious
" behaviour as the window layout will change during processing.
nnoremap <c-w><c-a> :call StackWindow()<cr>
command! -nargs=? StackWindow :call StackWindow(<f-args>)
function! StackWindow(...)
  " set target window number, default to 0
  if a:0 > 0
    let target_win = a:1
  else
    let target_win = 0
  endif
  let target_buf = winbufnr(target_win)
  if target_win != 0
    exe target_win . "wincmd w"
  endif
  close
  wincmd b | exe "belowright " . "sbuffer " . target_buf
endfunction

" vim:tw=78 ts=2 sw=2 et fdm=marker:
