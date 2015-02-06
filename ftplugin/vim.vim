" Personal Vim filetype plugin
" Author: Bohr Shaw <pubohr@gmail.com>

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
  " this variable will be set later when sourcing $VIMRUNTIME/ftplugin/vim.vim
endif

" Execute lines, or echo the value of an expression
nnoremap <buffer><silent> R mt:set operatorfunc=vimrc#run<CR>g@
nmap <buffer> Rr RVl
nnoremap <buffer><expr> RR ':'.(g:loaded_scriptease?'Runtime':'source %').'<CR>'
xnoremap <buffer><silent> R mt:<C-U>call vimrc#run(visualmode())<CR>

" Enable omni completion for vim scripts
set omnifunc=syntaxcomplete#Complete

" Indent
set sw=2 ts=2 sts=2
