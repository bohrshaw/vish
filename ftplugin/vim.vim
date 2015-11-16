if exists("b:did_ftplugin")
  finish
endif

setlocal shiftwidth=2 tabstop=2 softtabstop=2
setlocal textwidth=80
setlocal omnifunc=syntaxcomplete#Complete
call run#map()
