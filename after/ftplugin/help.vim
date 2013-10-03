" Use 'q' to close the help window
noremap <buffer> q <C-W>c

" Jump to a subject quickly
nnoremap <buffer> <CR> <C-]>

" Goto a position specified with a pattern 'count' times.
function! s:goto(pattern, ...)
    let counter = v:count1
    let flag = a:0 == 0 ? '' : a:1
    while counter > 0
        " search without affecting search history
        silent call search(a:pattern, flag)
        let counter = counter - 1
    endwhile
endfunction

" Goto to an option.
nnoremap <silent> <buffer> o :<C-U>call <SID>goto("'" . '\S\+' . "'")<CR>
nnoremap <silent> <buffer> O :<C-U>call <SID>goto("'" . '\S\+' . "'", 'b')<CR>

" Goto to a subject.
" Don't map <Tab> because <C-I> will also be mapped.
" 'I' is the initial of 'Insignia' which is a synonym of 'Tag'
nnoremap <silent> <buffer> i :<C-U>call <SID>goto('\|\S\+\|')<CR>
nnoremap <silent> <buffer> I :<C-U>call <SID>goto('\|\S\+\|', 'b')<CR>
