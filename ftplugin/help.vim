autocmd BufWinEnter <buffer> setlocal relativenumber
setlocal keywordprg=:help " man by default in terminal Vim
nnoremap <buffer> q <C-W>c
nnoremap <buffer> <CR> <C-]>
" :help help-writing
nnoremap <silent><nowait><buffer><Tab> :call ftplugin#help_goto('\v[\|*]\S+[\|*]')<CR>
nnoremap <silent><nowait><buffer><S-Tab> :call ftplugin#help_goto('\v[\|*]\S+[\|*]', 'b')<CR>
nnoremap <silent> <buffer> ]* :call ftplugin#help_goto('\*\S\+\*')<CR>
nnoremap <silent> <buffer> [* :call ftplugin#help_goto('\*\S\+\*', 'b')<CR>
nnoremap <silent> <nowait> <buffer> ]o :call ftplugin#help_goto('''\l\{2,}''')<CR>
nnoremap <silent> <nowait> <buffer> [o :call ftplugin#help_goto('''\l\{2,}''', 'b')<CR>
" Mappings for executing codes
call ftplugin#vim_map()
