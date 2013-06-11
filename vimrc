" This is a vimrc file digging out the full power of vim.

" Pathogen and bundle configuration {{{1
" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

" Source pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim

" Rename a bundle like "rails" to "rails~" to disable it
" Or add disabled bundles(directories) to the list bellow.
let g:pathogen_disabled = []

" Source the bundle configuration file
source ~/.vimrc.bundle

call pathogen#infect()
" }}}1

" Source a common vimrc file(vimrc.core)
source ~/.vimrc.core

" Choose a color scheme
if has('gui_running')
    color solarized
else
  if has('unix')
    color solarized
  else
    color vividchalk
  endif
endif

" vim:ft=vim tw=78 et sw=2 fdm=marker nowrap:
