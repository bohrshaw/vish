" File: vimrc
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: vim default version configuration.

" Vundle and bundle configuration {{{1
" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

" Vundle initialization
set nocompatible
filetype off " required!
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Source the bundle configuration file
source ~/.vimrc.bundle

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
