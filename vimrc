" Description: Vim configuration for the default version.
" Author: Bohr Shaw(pubohr@gmail.com)

" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

" Core configuration
source ~/.vim/vimrc.core

" Configure vundle
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Include and configure bundles
source ~/.vim/vimrc.bundle

filetype plugin indent on " must be after pathogen or vundle setup
syntax on

" Apply a color scheme
if has('gui_running')
  color base16-solarized
elseif has('unix')
  color terminater
endif

" vim:ft=vim tw=78 et sw=2 nowrap:
