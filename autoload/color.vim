function! color#highlight()
  let [tf, tb, gf, gb] = &background == 'dark' ?
        \ ['214', '0', '#ffaf00', '#000000'] :
        \ ['0', '40', '#000000', '#00df00']
  let [tfn, tbn, gfn, gbn] = &background == 'dark' ?
        \ ['34', '0', '#00af00', '#000000'] :
        \ ['0', '247', '#000000', '#9e9e9e']
  execute 'hi StatusLine term=bold cterm=bold ctermfg='.tf 'ctermbg='.tb
        \ 'gui=bold guifg='.gf 'guibg='.gb
  execute 'hi StatusLineNC term=bold cterm=bold ctermfg='.tfn 'ctermbg='.tbn
        \ 'gui=bold guifg='.gfn 'guibg='.gbn
  hi! link TabLineSel StatusLine
  hi! link TabLine StatusLineNC
  hi! link TabLineFill StatusLineNC

  let [tfm, tbm, gfm, gbm] = ['0', '220', '#000000', '#ffdf00']
  execute 'hi WildMenu term=bold cterm=bold ctermfg='.tfm 'ctermbg='.tbm
        \ 'gui=bold guifg='.gfm 'guibg='.gbm

  let [tf1, gf1, tf2, gf2, tf3, gf3] = &background == 'dark' ?
        \ ['123', '#87FFFF', '218', '#ffafdf', '9', '#ff6666'] :
        \ ['21', '#0000ff', '92', '#8700d7', '196', '#ff0000']
  execute 'hi User1 term=bold cterm=bold ctermfg='.tf1 'ctermbg='.tb
        \ 'gui=bold guifg='.gf1 'guibg='.gb
  execute 'hi User2 term=bold cterm=bold ctermfg='.tf2 'ctermbg='.tb
        \ 'gui=bold guifg='.gf2 'guibg='.gb
  execute 'hi User3 term=bold cterm=bold ctermfg='.tf3 'ctermbg='.tb
        \ 'gui=bold guifg='.gf3 'guibg='.gb
endfunction
