function! b#colors#()
  let c = get(g:, 'colors_name', '')
  if c == 'seoul256'
    hi VertSplit term=NONE cterm=NONE ctermfg=16 ctermbg=237
          \ gui=NONE guifg=#777777 guibg=#3a3a3a
  elseif c == 'solarized'
    runtime autoload/b/colors/solarized.vim
  elseif c == 'github'
    hi CursorLine cterm=NONE gui=NONE ctermbg=253 guibg=#D8D8DD
  elseif c == 'zenburn'
    hi Comment gui=none
  endif
endfunction
