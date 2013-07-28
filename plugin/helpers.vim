" File: helpers.vim
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: Various help commands, mappings and functions.

" Vim itself {{{1
" Source vim scripts {{{2
" Source current line
nnoremap <leader>S ^"zy$:@z<bar>echo "Current line sourced."<cr>

" Source visual selection even including a line continuation symbol '\'
vnoremap <leader>S "zy:let @z = substitute(@z, "\n *\\", "", "g")<bar>@z<bar>
      \echo "Selection sourced."<cr>

" Source a range of lines, default to the current line
command! -range Source <line1>,<line2>g/./exe getline('.')
" }}}2

" Display the help window in a new tab
command! -nargs=? -complete=help H tab h <args>

" Calculate the time spending on executing commands
function! Time(commands)
  let time_start = reltime()
  exe a:commands
  let time = reltime(time_start)
  echo 'Total Seconds: ' . split(reltimestr(time))[0]
endfunction
command! -nargs=1 -complete=command Time call Time(<q-args>)

" Editting {{{1
" Appends the current date or time after the cursor
nnoremap <leader>at a<C-R>=strftime("%a %b %d %H:%M:%S %Y")<CR><Esc>

" Swap two adjacent keywords
nnoremap <leader>sw :s/\v(<\k*%#\k*>)(.{-})(<\k+>)/\3\2\1/<cr>``

" Remove adjacent duplicate lines
command! UniqAdjacent g/\v^(.*)\n\1$/d

" Remove duplicate non-empty lines
command! Uniq g/^./if search('^\V'.escape(getline('.'),'\').'\$', 'bW') | delete | endif <NL> silent! normal! ``
" This one is far slower than the above
" command! Uniq g/\v^(.+\n)(.*\n){-}(\1)/d <NL> silent! normal! ``

" An abbreviation for the current file's relative path
cabbrev %% <C-R>=expand('%:h').'/'<cr>

" Edit a file in a window or tab
nmap <leader>ee :e %:h/
nmap <leader>es :sp %:h/
nmap <leader>ev :vs %:h/
nmap <leader>et :tabe %:h/

" Utilities {{{1
" Create a scratch buffer
command! Scratch e __Scratch__ | set buftype=nofile bufhidden=hide

" Calculate the size of the current buffer
function BufSize()
  return line2byte(line('$') + 1) - 1
endfunction
command! BufSize :echo BufSize()

" Create a directory under the current path
command! -nargs=1 -complete=dir Mkdir :call mkdir(getcwd() . "/" . <q-args>, "p")

" Simple letter encoding with rot13
command! Rot13 exe "normal ggg?G''"

" Calculate words frequency
command! -range=% WordFrequency <line1>,<line2>call helpers#word_frequency()

" Quite diff mode and close other diff buffers
noremap <leader>do :diffoff \| windo if &diff \| hide \| endif<cr>

" Diff with another file
command! -nargs=? -complete=buffer DiffWith call helpers#DiffWith(<f-args>)

" Wipe out all unlisted buffers
command! BwUnlisted call helpers#bufffer_wipe_unlisted()

" Append a mode line
command! AppendModeline call helpers#appendModeline()

" External interaction {{{1
" Execute an external command silently
command! -nargs=1 -complete=shellcmd Silent call system(<q-args>)

" Search words via the web
nnoremap gG :call netrw#NetrwBrowseX("http://www.google.com.hk/search?q=".expand("<cword>"),0)<cr>
nnoremap gT :call netrw#NetrwBrowseX("http://translate.google.com.hk/#auto/zh-CN/".expand("<cword>"),0)<cr>
nnoremap gW :call netrw#NetrwBrowseX("http://en.wikipedia.org/wiki/Special:Search?search=".expand("<cword>"),0)<cr>
command! -nargs=1 Google call netrw#NetrwBrowseX("http://www.google.com.hk/search?q=".expand("<args>"),0)

" }}}1

" vim:tw=78 ts=2 sw=2 et fdm=marker:
