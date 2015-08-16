if exists("b:did_ftplugin")
  finish
endif

if &buftype == 'help'
  nnoremap <buffer> q <C-W>c
endif
nnoremap <buffer> <CR> <C-]>
" :help help-writing
nnoremap <silent><buffer><M-]> :call ftplugin#help_goto('\*\S\+\*')<CR>
nnoremap <silent><buffer><M-[> :call ftplugin#help_goto('\*\S\+\*', 'b')<CR>
let s:map_pre = 'nnoremap <silent><buffer>'.(&buftype == 'help' ? '' : '<LocalLeader>')
execute s:map_pre.'i :call ftplugin#help_goto('.string('\|\S\+\|').')<CR>'
execute s:map_pre.'I :call ftplugin#help_goto('.string('\|\S\+\|').', "b")<CR>'
execute s:map_pre.'o :call ftplugin#help_goto('.string('''\l\{2,}''').')<CR>'
execute s:map_pre.'O :call ftplugin#help_goto('.string('''\l\{2,}''').', "b")<CR>'
" Mappings for executing codes
call ftplugin#vim_map()

setlocal relativenumber
setlocal keywordprg=:help " man by default in terminal Vim
" Fix some window options when open this buffer in an existing window
augroup help
  autocmd!
  if &buftype == 'help'
    autocmd BufWinEnter <buffer> set nolist foldmethod=manual
  endif
augroup END
