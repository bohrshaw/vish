" Detect files' types. You can also create a separate file like
" 'ftdetect/nginx.vim'.

if !exists("autocommands_loaded")
  let autocommands_loaded = 1

  " Detect vimperator configuration files
  au BufNewFile,BufRead *vimperatorrc*,*.vimp set filetype=vimperator

  " Detect nginx configuration files
  au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif 

  autocmd FileType python setlocal sw=4 ts=4 sts=4

  autocmd FileType PS1 setlocal fileformat=dos
endif
