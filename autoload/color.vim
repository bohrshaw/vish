function! color#highlight()
  " DarkGreen, DarkYellow, Gray, Green
  let [bt, bg, ft, fg, btn, bgn, ftn, fgn] = &background == 'dark' ?
        \ ['22', '#005f00', '214', '#ffaf00', '237', '#3a3a3a', '40', '#00d700'] :
        \ ['40', '#00df00', '88', '#870000', '250', '#bcbcbc', '22', '#005f00']
  execute 'hi StatusLine term=bold cterm=bold ctermfg='.ft 'ctermbg='.bt
        \ 'gui=bold guifg='.fg 'guibg='.bg
  execute 'hi StatusLineNC term=NONE cterm=NONE ctermfg='.ftn 'ctermbg='.btn
        \ 'gui=NONE guifg='.fgn 'guibg='.bgn
  hi! link TabLineSel StatusLine
  hi! link TabLine StatusLineNC
  hi! link TabLineFill StatusLineNC
  " Cyan/Blue, Magenta/Purple, Red
  let [ft1, fg1, ft2, fg2, ft3, fg3] = &background == 'dark' ?
        \ ['123', '#87FFFF', '218', '#ffafdf', '9', '#ff6666'] :
        \ ['21', '#0000ff', '92', '#8700d7', '196', '#ff0000']
  execute 'hi User1 term=bold cterm=bold ctermfg='.ft1 'ctermbg='.bt
        \ 'gui=bold guifg='.fg1 'guibg='.bg
  execute 'hi User2 term=bold cterm=bold ctermfg='.ft2 'ctermbg='.bt
        \ 'gui=bold guifg='.fg2 'guibg='.bg
  execute 'hi User3 term=bold cterm=bold ctermfg='.ft3 'ctermbg='.bt
        \ 'gui=bold guifg='.fg3 'guibg='.bg
endfunction
