" Only detect file types.
"
" You may create a separate file like 'ftdetect/nginx.vim'
" for detecting the nginx file type.

if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  " Detect vimperator configuration files
  au BufNewFile,BufRead *vimperatorrc*,*.vimp setfiletype vimperator

  " Detect nginx configuration files
  au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* setfiletype nginx
augroup END
