" Only detect file types.
"
" You may create a separate file like 'ftdetect/nginx.vim'
" for detecting the nginx file type.

if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  autocmd BufNewFile,BufRead *vimperatorrc*,*.vimp setfiletype vimperator
  autocmd BufNewFile,BufRead /etc/nginx/*,/usr/local/nginx/conf/* setfiletype nginx
augroup END
