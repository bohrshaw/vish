" Depend on "tern_for_vim"

nnoremap <buffer><silent>K :TernDoc<CR>
nnoremap <buffer><silent><LocalLeader>K :TernDocBrowse<CR>
nnoremap <buffer><silent><LocalLeader>k :TernType<CR>
nnoremap <buffer><silent><LocalLeader>i :call tern#LookupArgumentHints()<CR>
nnoremap <buffer><silent>gd :TernDef<CR>
nnoremap <buffer><silent><LocalLeader>r :TernRefs<CR>
nnoremap <buffer><silent><LocalLeader>n :TernRename<CR>
