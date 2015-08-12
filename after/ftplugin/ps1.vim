if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

setlocal fileformat=dos
setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab
