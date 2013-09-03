" Use 'q' to close the help window
noremap <buffer> q <c-w>c

" Jump to a subject quickly
noremap <buffer> <cr> <c-]>

" Navigate to an option (without affecting search history)
noremap <silent> <buffer> o :call search("'" . '\S\+' . "'")<cr>
noremap <silent> <buffer> O :call search("'" . '\S\+' . "'", 'b')<cr>

" Jump to a subject (without affecting search history)
" 'I' is the initial of 'Insignia' which is a synonym of 'Tag'
noremap <silent> <buffer> <Tab> :call search('\|\S\+\|')<cr>
noremap <silent> <buffer> <S-Tab> :call search('\|\S\+\|', 'b')<cr>
noremap <silent> <buffer> i :call search('\|\S\+\|')<cr>
noremap <silent> <buffer> I :call search('\|\S\+\|', 'b')<cr>
