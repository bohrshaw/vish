if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

setlocal makeprg=shellcheck\ -f\ gcc\ %
setlocal shiftwidth=2 tabstop=2 softtabstop=2
