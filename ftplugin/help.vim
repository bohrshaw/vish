" Use 'q' to close the help window
noremap <buffer> q <C-W>c

" Jump to a subject quickly
nnoremap <buffer> <CR> <C-]>

" Goto to an option.
nnoremap <silent> <buffer> o :<C-U>call ftplugin#help_goto("'" . '\S\+' . "'")<CR>
nnoremap <silent> <buffer> O :<C-U>call ftplugin#help_goto("'" . '\S\+' . "'", 'b')<CR>

" Goto to a subject.
" Don't map <Tab> because <C-I> will also be mapped.
" 'I' is the initial of 'Insignia' which is a synonym of 'Tag'
nnoremap <silent> <buffer> i :<C-U>call ftplugin#help_goto('\|\S\+\|')<CR>
nnoremap <silent> <buffer> I :<C-U>call ftplugin#help_goto('\|\S\+\|', 'b')<CR>
