if exists("b:did_after_ftplugin")
  finish
endif
let b:did_after_ftplugin = 1

" Note: `shellcheck` removed 'zsh' support as it was never up to par.
" https://github.com/koalaman/shellcheck/commit/ed56a837c33caba7788b96a70f6c0f7eb5642e27
if executable('shellcheck')
  setlocal makeprg=shellcheck\ --format=gcc\ --shell=zsh\ %
endif

setlocal shiftwidth=2 tabstop=2 softtabstop=2
