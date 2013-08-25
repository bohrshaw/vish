" Description: Vim configuration for the default version.
" Author: Bohr Shaw <pubohr@gmail.com>

" Core configuration
source ~/.vim/vimrc.core

" Bundle configuration
source ~/.vim/vimrc.bundle

" Post configuration
filetype plugin indent on " must be after pathogen or vundle setup
syntax on

if has('gui_running')
  color base16-solarized
elseif has('unix')
  color terminater
endif

" vim:ft=vim tw=78 et sw=2 nowrap:
