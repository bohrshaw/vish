if exists("b:did_ftplugin")
  finish
endif

setlocal shiftwidth=2 tabstop=2 softtabstop=2
setlocal omnifunc=syntaxcomplete#Complete
call ftplugin#vim_map()
