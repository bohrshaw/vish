" :help new-filetype
" See the logic of `:filetype on` in "$VIMRUNTIME/filetype.vim".

if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  " File types would be mis-detected (e.g. as conf)
  autocmd BufNewFile,BufRead *.snippets setfiletype snippets

  " New file types
  autocmd BufNewFile,BufRead /etc/nginx/*,/usr/local/nginx/conf/* setfiletype nginx
augroup END
