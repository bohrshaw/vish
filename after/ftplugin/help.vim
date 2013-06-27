" Use 'q' to close the help window
noremap <buffer> q <c-w>c

" Jump to a subject quickly
noremap <buffer> <cr> <c-]>

" Navigate to an option (without affecting search history)
noremap <silent> <buffer> o :call search("'" . '\S\+' . "'")<cr>
noremap <silent> <buffer> O :call search("'" . '\S\+' . "'", 'b')<cr>

" Jump to a subject (without affecting search history)
noremap <silent> <buffer> s :call search('\|\S\+\|')<cr>
noremap <silent> <buffer> S :call search('\|\S\+\|', 'b')<cr>
