" File: vimrc
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: vim default version configuration.

" Vundle initialization {{{1
" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Bundle configuration {{{1
source ~/.vim/vimrc.bundle

" Vim configuration {{{1
source ~/.vim/vimrc.core

" }}}1

" vim:ft=vim tw=78 et sw=2 fdm=marker nowrap:
