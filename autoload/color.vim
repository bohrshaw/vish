function! color#highlight()
  " DarkGreen, DarkYellow, Gray, Green
  let [tf, tb, gf, gb] = &background == 'dark' ?
        \ ['220', '22', '#ffdf00', '#005f00'] :
        \ ['88', '40', '#870000', '#00df00']
  let [tfn, tbn, gfn, gbn] = &background == 'dark' ?
        \ ['40', '237', '#00d700', '#3a3a3a'] :
        \ ['22', '250', '#005f00', '#bcbcbc']
  execute 'hi StatusLine term=bold cterm=bold ctermfg='.tf 'ctermbg='.tb
        \ 'gui=bold guifg='.gf 'guibg='.gb
  execute 'hi StatusLineNC term=NONE cterm=NONE ctermfg='.tfn 'ctermbg='.tbn
        \ 'gui=NONE guifg='.gfn 'guibg='.gbn
  hi! link TabLineSel StatusLine
  hi! link TabLine StatusLineNC
  hi! link TabLineFill StatusLineNC
  let [tfm, tbm, gfm, gbm] = ['0', '220', '#000000', '#ffdf00']
  execute 'hi WildMenu term=NONE cterm=NONE ctermfg='.tfm 'ctermbg='.tbm
        \ 'gui=NONE guifg='.gfm 'guibg='.gbm
  " Cyan/Blue, Magenta/Purple, Red
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
