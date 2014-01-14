" textobj-neighbour.vim -- next/last text object definition
" Author: Bohr Shaw <pubohr@gmail.com>

command! -nargs=1 OXnoremap onoremap <silent> <args><Bar> xnoremap <silent> <args>

OXnoremap an :<c-u>call <SID>neighbour('a')<cr>
OXnoremap in :<c-u>call <SID>neighbour('i')<cr>
OXnoremap al :<c-u>call <SID>neighbour('a', 1)<cr>
OXnoremap il :<c-u>call <SID>neighbour('i', 1)<cr>

function! s:neighbour(motion, ...)
  let char = getchar()
  " Todo: escape to normal mode after `cin<Esc>`
  if char == 27 | return | endif " return for <Esc>
  let char = nr2char(char)
  if char ==# 'b'
    let char = '('
  elseif char ==# 'B'
    let char = '{'
  elseif char =~ '["''`]'
    " Move to the pair end if the number of ["'`] before/after the cursor is odd
    let range = a:0 ? "col('.')-1:" : ":col('.')"
    if len(split(eval("getline('.')[".range."]"), char, 1)) % 2 == 0
      call search('\V'.char, a:0 ? 'bW' : 'W')
    endif
  elseif char ==# 't'
    let char = '<\(\w\+\)\.\{-}>\ze\_.\{-}</\1>\c'
  elseif char !~ '[wWsp(){}<>\[\]]'
    return
  endif
  call search('\V'.char, a:0 ? 'bW' : 'W')
  execute "normal! v" . a:motion . char
endfunction