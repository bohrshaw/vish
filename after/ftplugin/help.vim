if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

" Show hidden characters, useful for copying text
setlocal conceallevel=0
