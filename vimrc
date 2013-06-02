" This is a vimrc file digging out the full power of vim.

" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

" Section: pathogen {{{1

runtime bundle/vim-pathogen/autoload/pathogen.vim

" Rename a bundle like "rails" to "rails~" to disable it
" Or add disabled bundles(directories) to the list bellow.
let g:pathogen_disabled = []

if has('win32') || !has("signs") || !has("clientserver")
    call add(g:pathogen_disabled, 'vim-ruby-debugger')
    call add(g:pathogen_disabled, 'vim-tbone')
endif

if !executable('ack-grep') && !executable('ack')
    call add(g:pathogen_disabled, 'ack.vim')
endif

call pathogen#infect()

" }}}1

" Source a common vimrc file(vimrc.core)
source ~/.vimrc.core

" Source the bundle configuration file
source ~/.vimrc.bundle

" shortcut to edit vimrc files in a new tab
command! Vrc :tabe ~/configent/vim/vimrc
command! Vrcb :tabe ~/configent/vim/vimrc.bundle

" vim:ft=vim tw=78 et sw=2 fdm=marker nowrap:
