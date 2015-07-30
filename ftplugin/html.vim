if exists("b:did_ftplugin")
  finish
endif

" Format the current HTML file through an external filter program 'tidy'
command! -buffer Tidy silent %!tidy -indent -wrap 0 -quiet -utf8 --show-warnings 0

