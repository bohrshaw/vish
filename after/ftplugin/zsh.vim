if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

if executable('shellcheck')
  setlocal makeprg=shellcheck\ --format=gcc\ --shell=zsh\ %
endif
setlocal shiftwidth=2 tabstop=2 softtabstop=2
