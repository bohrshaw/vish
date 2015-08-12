if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

" Avoid deleting b:did_ftplugin when setting filetype from the modeline, thus
" speed up file re-sourcing. As a consequence, it may not be properly undo
" filetype settings when changing the filetype.
unlet b:undo_ftplugin

" Show hidden characters, useful for copying text
setlocal conceallevel=0
