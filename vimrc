" Description: Vim configuration for the default version.
" Author: Bohr Shaw <pubohr@gmail.com>

" Note:
" In order to reduce the startup time, you can do profiling with this command:
" vim --startuptime startup_profiling

" Options should set as early as possible
set nocompatible
set encoding=utf-8 " Allow mappings start with the ALT key work properly.
let mapleader = ' '
let maplocalleader = ','

" Vundle initialization
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
let g:vundle_default_git_proto = 'git'

" Set this early to improve startup performance.
" But it must be after the initialization of pathogen or vundle.
filetype plugin indent on

" Bundle configuration
source ~/.vim/vimrc.bundle

" Core configuration
source ~/.vim/vimrc.core

" Post configuration
if has('gui_running')
  color base16-solarized
elseif has('unix')
  color terminater
endif
syntax on

" vim:ft=vim tw=78 et sw=2 nowrap:
