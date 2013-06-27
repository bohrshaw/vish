" File: vimrc
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: vim default version configuration.

" Pathogen and bundle configuration {{{1
" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

" Source pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim

" Rename a bundle like "rails" to "rails~" to disable it
" Or add disabled bundles(directories) to the list bellow.
let g:pathogen_disabled = []

" A command letting external scripts parse all the bundled plugins
" but actually doing nothing
command! -buffer -nargs=1 Bundle :

" A command letting pathogen disable a bundle
command! -buffer -nargs=1 Dundle call add(g:pathogen_disabled, split(<args>, '/')[1])

" Disable vundle in case it is installed
Dundle 'gmarik/vundle'

" Source the bundle configuration file
source ~/.vimrc.bundle

call pathogen#infect()

" Source the core vim configuration file {{{1
source ~/.vimrc.core

" Choose a color scheme {{{1
if has('gui_running')
    color solarized
else
  if has('unix')
    color solarized
  else
    color vividchalk
  endif
endif
"}}}1

" vim:ft=vim tw=78 et sw=2 fdm=marker nowrap:
