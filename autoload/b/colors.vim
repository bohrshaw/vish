function! b#colors#()
  if g:colors_name == 'seoul256'
    hi VertSplit term=NONE cterm=NONE ctermfg=16 ctermbg=237
          \ gui=NONE guifg=#777777 guibg=#3a3a3a
  elseif g:colors_name == 'solarized'
    runtime autoload/b/colors/solarized.vim
  elseif g:colors_name == 'github'
    hi CursorLine cterm=NONE gui=NONE ctermbg=253 guibg=#D8D8DD
  endif
endfunction
