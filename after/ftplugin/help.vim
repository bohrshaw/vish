" Use 'q' to close the help window
noremap <buffer> q <c-w>c

" Jump to a subject quickly
noremap <buffer> <cr> <c-]>

" Navigate to an option (without affecting search history)
noremap <buffer> o :call search("'" . '\S\+' . "'")<cr>
noremap <buffer> O :call search("'" . '\S\+' . "'", 'b')<cr>

" Jump to a subject (without affecting search history)
noremap <buffer> s :call search('\|\S\+\|')<cr>
noremap <buffer> S :call search('\|\S\+\|', 'b')<cr>
