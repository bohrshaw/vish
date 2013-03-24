" Detect files' types. You can also create a separate file like
" 'ftdetect/nginx.vim'.

" Detect vimperator configuration files
au BufNewFile,BufRead *vimperatorrc*,*.vimp set filetype=vimperator

" Detect nginx configuration files
au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif 
