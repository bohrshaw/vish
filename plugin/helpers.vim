" File: helpers.vim
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: Various help commands, mappings and functions.

" Editting {{{1
" Appends the current date and time after the cursor
nmap <leader>at a<C-R>=strftime("%c")<CR><Esc>

" Swap two adjacent keywords
nnoremap <leader>sw :s/\v(<\k*%#\k*>)(\_.{-})(<\k+>)/\3\2\1/<cr>``

" Remove adjacent duplicate lines by matching two lines first
command! UniqAdjacent g/\v^(.*)$\n\1$/d
"command! UniqAdjacent g/\v%(^\1$\n)@<=(.*)$/d

" Remove duplicate non-empty lines
command! Uniq g/\v^(.+)$\_.{-}\zs(^\1$)/d
" command! Uniq g/^/kl |
"       \ if search('^' . escape(getline('.'), '~\.*[]^$/') . '$', 'bW') | 'ld | endif

" Editing in a chosen window or tab
cnoremap %% <C-R>=expand('%:h').'/'<cr>
nmap <leader>ee :e %%
nmap <leader>es :sp %%
nmap <leader>ev :vsp %%
nmap <leader>et :tabe %%

" Utilities {{{1
" Create a scratch buffer
command! Scratch e __Scratch__ | set buftype=nofile bufhidden=hide

" Quite diff mode and close other diff buffers
noremap <leader>do :diffoff \| windo if &diff \| hide \| endif<cr>

" Create a directory based the current buffer's path
command! -nargs=1 -complete=dir Mkdir :call mkdir(getcwd() . "/" . <q-args>, "p")

" Simple letter encoding with rot13
command! Rot13 exe "normal ggg?G''"

" Source vim scripts {{{2
" Source current line
nnoremap <leader>S ^"zy$:@z<bar>echo "Current line sourced."<cr>

" Source visual selection even including a line continuation symbol '\'
vnoremap <leader>S "zy:let @z = substitute(@z, "\n *\\", "", "g")<bar>@z<bar>
      \echo "Selection sourced."<cr>

" Source a range of lines, default to the current line
command! -range Source <line1>,<line2>g/./exe getline('.')

" Search words via the web {{{2
nnoremap gG :call netrw#NetrwBrowseX("http://www.google.com.hk/search?q=".expand("<cword>"),0)<cr>
nnoremap gT :call netrw#NetrwBrowseX("http://translate.google.com.hk/#auto/zh-CN/".expand("<cword>"),0)<cr>
nnoremap gW :call netrw#NetrwBrowseX("http://en.wikipedia.org/wiki/Special:Search?search=".expand("<cword>"),0)<cr>
command! -nargs=1 Google call netrw#NetrwBrowseX("http://www.google.com.hk/search?q=".expand("<args>"),0)
"}}}2

" Calculate words frequency
command! -range=% WordFrequency <line1>,<line2>call helpers#word_frequency()

" Diff with another file
command! -nargs=? -complete=buffer DiffWith call helpers#DiffWith(<f-args>)

" Append a mode line
command! AppendModeline call helpers#appendModeline()

" }}}1

" vim:tw=78 ts=2 sw=2 et fdm=marker:
