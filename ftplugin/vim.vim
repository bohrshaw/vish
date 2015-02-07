" Personal Vim filetype plugin
" Author: Bohr Shaw <pubohr@gmail.com>

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
  " this variable will be set later when sourcing $VIMRUNTIME/ftplugin/vim.vim
endif

" Execute lines, or echo the value of an expression
nnoremap <buffer><silent> R mz:set operatorfunc=vimrc#run<CR>g@
" use :normal to support mapping count
nmap <buffer><silent> RR :normal RVl<CR>
nnoremap <buffer><expr> R% ':'.(g:loaded_scriptease?'Runtime':'source %').'<CR>'
xnoremap <buffer><silent> R mz:<C-U>call vimrc#run(visualmode())<CR>

" Enable omni completion for vim scripts
set omnifunc=syntaxcomplete#Complete

" Indent
set sw=2 ts=2 sts=2
