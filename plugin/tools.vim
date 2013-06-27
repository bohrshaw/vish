" File: tools.vim
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: Small powerful tolls.

command! -range=% WordFrequency <line1>,<line2>call tools#word_frequency()
