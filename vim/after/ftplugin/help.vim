" Use 'q' to close the help window
noremap <buffer> q <c-w>c

" Jump to a subject quickly
noremap <buffer> <cr> <c-]>

" Navigate to an option (without affecting search history)
noremap <buffer> o :call search("'" . '\S\+' . "'")<cr>
noremap <buffer> O :call search("'" . '\S\+' . "'", 'b')<cr>

" Navigate to a link/tag (without affecting search history)
noremap <buffer> <tab> :call search('\|\S\+\|')<cr>
noremap <buffer> <s-tab> :call search('\|\S\+\|', 'b')<cr>
