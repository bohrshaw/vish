if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

setlocal foldlevel=1
setlocal shiftwidth=4 tabstop=4 softtabstop=4

" Visually ignore imperfect syntax
hi def link markdownItalic              NONE
hi def link markdownItalicDelimiter     NONE
hi def link markdownBold                NONE
hi def link markdownBoldDelimiter       NONE
hi def link markdownBoldItalic          NONE
hi def link markdownBoldItalicDelimiter NONE
