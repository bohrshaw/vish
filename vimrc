" File: vimrc
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: vim default version configuration.

" Bundles {{{1
" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

" Setup vundle
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Include and configure bundles
source ~/.vim/vimrc.bundle

" Configuration {{{1
" Source the fundamental vimrc file
source ~/.vim/vimrc.core

" Apply a color scheme
if has('gui_running') || has('unix')
  color solarized
endif

" }}}1

" vim:ft=vim tw=78 et sw=2 nowrap fdm=marker fdl=1:
