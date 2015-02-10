" Personal Vim filetype plugin
" Author: Bohr Shaw <pubohr@gmail.com>

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
  " this variable will be set later when sourcing $VIMRUNTIME/ftplugin/vim.vim
endif

" Mappings for executing codes
call ftplugin#vim_map()

" Enable omni completion for vim scripts
set omnifunc=syntaxcomplete#Complete

" Indent
set sw=2 ts=2 sts=2
