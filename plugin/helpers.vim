" Description: Various helpers.
" Author: Bohr Shaw <pubohr@gmail.com>

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

" Manipulating text {{{1
" Read only {{{2
" Calculate words frequency
command! -range=% WordFrequency <line1>,<line2>call helpers#word_frequency()

" Calculate the size of the current buffer
command! BufSize :echo line2byte(line('$') + 1) - 1

" }}}2

" Switch case of the current word
noremap <A-u> mzg~iw`z

" Appends the current date or time after the cursor
nnoremap <leader>at a<C-R>=strftime("%a %b %d %H:%M:%S %Y")<CR><Esc>

" Swap two adjacent keywords
nnoremap <leader>sw :s/\v(<\k*%#\k*>)(.{-})(<\k+>)/\3\2\1/<cr>``

" Remove trailing white spaces
command! Trim %s/\s\+$//

" Remove duplicate, consecutive lines
command! UniqConsecutive sort /$^/ u
" command! UniqConsecutive g/\v^(.*)\n\1$/d

" Remove duplicate, nonconsecutive and nonempty lines
command! UniqNonconsecutiveNonempty g/^./if search('^\V'.escape(getline('.'),'\').'\$', 'bW') | delete | endif <NL> silent! normal! ``
" This one is far slower than the above
" command! UniqNonconsecutiveNonempty g/\v^(.+)$\_.{-}^\1$/d <NL> silent! normal! ``

" Append a mode line
command! AppendModeline call helpers#appendModeline()

" Simple letter encoding with rot13
command! Rot13 exe "normal ggg?G''"

" Manipulating others {{{1
" Edit a file in the same directory of the current file
NXnoremap <leader>ee :e %:h/
NXnoremap <leader>es :sp %:h/
NXnoremap <leader>ev :vs %:h/
NXnoremap <leader>et :tabe %:h/

" Get the relative path of the current file
cabbrev %% <C-R>=expand('%:h').'/'<cr>

" Create a scratch buffer
command! Scratch e __Scratch__ | set buftype=nofile bufhidden=hide

" Create a directory under the current path
command! -nargs=1 -complete=dir Mkdir :call mkdir(getcwd() . "/" . <q-args>, "p")

" Diff with another file
command! -nargs=? -complete=buffer DiffWith call helpers#DiffWith(<f-args>)

" Quit diff mode and close other diff buffers
noremap <leader>do :diffoff \| windo if &diff \| hide \| endif<cr>

" Wipe out all unlisted buffers
command! BwUnlisted call helpers#bufffer_wipe_unlisted()

" External interaction {{{1
" Execute an external command silently
command! -nargs=1 -complete=shellcmd Silent call system(<q-args>)

" Search words via the web
nnoremap gG :call netrw#NetrwBrowseX("http://www.google.com.hk/search?q=".expand("<cword>"),0)<cr>
nnoremap gT :call netrw#NetrwBrowseX("http://translate.google.com.hk/#auto/zh-CN/".expand("<cword>"),0)<cr>
nnoremap gW :call netrw#NetrwBrowseX("http://en.wikipedia.org/wiki/Special:Search?search=".expand("<cword>"),0)<cr>
command! -nargs=1 Google call netrw#NetrwBrowseX("http://www.google.com.hk/search?q=".expand("<args>"),0)

" vim:tw=78 ts=2 sw=2 et fdm=marker:
