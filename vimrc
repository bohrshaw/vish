" Description: Vim configuration for the default version.
" Author: Bohr Shaw <pubohr@gmail.com>

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

" vim:ft=vim tw=78 et sw=2 nowrap:
