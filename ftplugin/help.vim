if exists("b:did_ftplugin")
  finish
endif

nnoremap <buffer> q <C-W>c
nnoremap <buffer> <CR> <C-]>
" :help help-writing
nnoremap <silent><buffer><M-]> :call ftplugin#help_goto('\*\S\+\*')<CR>
nnoremap <silent><buffer><M-[> :call ftplugin#help_goto('\*\S\+\*', 'b')<CR>
nnoremap <silent><buffer>i :call ftplugin#help_goto('\|\S\+\|')<CR>
nnoremap <silent><buffer>I :call ftplugin#help_goto('\|\S\+\|', 'b')<CR>
nnoremap <silent><buffer>o :call ftplugin#help_goto('''\l\{2,}''')<CR>
nnoremap <silent><buffer>O :call ftplugin#help_goto('''\l\{2,}''', 'b')<CR>
" Mappings for executing codes
call ftplugin#vim_map()

setlocal relativenumber
setlocal keywordprg=:help " man by default in terminal Vim
