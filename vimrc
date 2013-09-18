" Description: Vim configuration for the default version.
" Author: Bohr Shaw <pubohr@gmail.com>

" Note:
" In order to reduce the startup time, you can do profiling with this command:
" vim --startuptime startup_profiling

" Core configuration
source ~/.vim/vimrc.core

" Vundle initialization
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

" Post configuration
if has('gui_running')
  color base16-solarized
elseif has('unix')
  color terminater
endif

" vim:ft=vim tw=78 et sw=2 nowrap:
