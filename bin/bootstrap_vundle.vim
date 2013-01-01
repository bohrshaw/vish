set nocompatible        " must be first line
" Setup vundle
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

let g:vundle_default_git_proto = 'git'
source $HOME/vimise/vimrc.bundle
