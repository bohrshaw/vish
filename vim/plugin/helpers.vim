" Various help commands, mappings and functions.

" Source current line
nnoremap <leader>S ^"zy$:@z<bar>echo "Current line sourced."<cr>

" Source visual selection even including a line continuation symbol '\'
vnoremap <leader>S "zy:let @z = substitute(@z, "\n *\\", "", "g")<bar>@z<bar>
      \echo "Selection sourced."<cr>

" Source a range of lines, default to the current line
command! -range Source <line1>,<line2>g/./exe getline('.')

" Appends the current date and time after the cursor
nmap <leader>at a<C-R>=strftime("%c")<CR><Esc>

" Swap two adjacent keywords
nnoremap <leader>sw :s/\v(<\k*%#\k*>)(\_.{-})(<\k+>)/\3\2\1/<cr>

" Create a directory based the current buffer's path
command! -nargs=? -complete=dir Mkdir :call mkdir(expand('%:p:h') . "/" . <q-args>, "p")

" Underline the current line with '=', frequently used in markdown headings
nnoremap <silent> <leader>ul :t.\|s/./=/g\|nohls<cr>

" Remove adjacent duplicate lines by matching two lines first
command! UniqAdjacent g/\v^(.*)$\n\1$/d
"command! UniqAdjacent g/\v%(^\1$\n)@<=(.*)$/d

" Remove duplicate non-empty lines
command! Uniq g/\v^(.+)$\_.{-}\zs(^\1$)/d
" command! Uniq g/^/kl |
"       \ if search('^' . escape(getline('.'), '~\.*[]^$/') . '$', 'bW') | 'ld | endif

" Display help window at bottom right
command! -nargs=? -complete=help H wincmd b | bel h <args>

" Simple letter encoding with rot13
command! Rot13 exe "normal ggg?G''"

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

" Open URL under cursor in browser
function! OpenURL(url) " {{{2
  if has("win32")
    exe "!start cmd /cstart /b ".a:url.""
  elseif $DISPLAY !~ '^\w'
    exe "silent !sensible-browser \"".a:url."\""
  else
    exe "silent !sensible-browser -T \"".a:url."\""
  endif
  redraw!
endfunction " }}}2
command! -nargs=1 OpenURL call OpenURL(<q-args>)
" nnoremap gf :OpenURL <cfile><CR>
nnoremap gG :OpenURL http://www.google.com/search?q=<cword><CR>
nnoremap gW :OpenURL http://en.wikipedia.org/wiki/Special:Search?search=<cword><CR>

" Diff current file with current saved file or a different buffer
function! DiffWith(...) " {{{2
  let filetype=&ft
  tab sp " Open current buffer in a new tab
  diffthis
  if a:0 == 0
 " Load the original file
    vnew | r # | normal! 1Gdd
 " Make it temp
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
  else
    exe "vert sb " . a:1
  endif
  diffthis
endfunction " }}}2
command! -nargs=? -complete=buffer DiffWith call DiffWith(<f-args>)

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" Files.
function! AppendModeline() " {{{2
  let modeline = printf(" vim:tw=%d ts=%d sw=%d et fdm=marker:", &textwidth, &shiftwidth, &tabstop)
  let modeline = substitute(&commentstring, "%s", modeline, "")
 " Append a new line and a modeline at the end of file
  call append(line("$"), ["", modeline])
endfunction " }}}2
command! AppendModeline call AppendModeline()

" execute current ruby file (make ruby)
command! RunRuby :let f=expand("%")|wincmd w|
            \ if bufexists("mr_output")|e! mr_output|else|sp mr_output|endif |
            \ execute '$!ruby "' . f . '"'|wincmd W

" Execute a file
function! Run()
  let old_makeprg = &makeprg
  let old_errorformat = &errorformat
  try
    let cmd = matchstr(getline(1),'^#!\zs[^ ]*')
    if exists('b:run_command')
      exe b:run_command
    elseif cmd != '' && executable(cmd)
      wa
      let &makeprg = matchstr(getline(1),'^#!\zs.*').' %'
      make
    elseif &ft == 'ruby'
      wa
      if executable(expand('%:p')) || getline(1) =~ '^#!'
        compiler ruby
        let &makeprg = 'ruby'
        make %
      elseif executable('pry')
        !pry -r"%:p"
      else
        !irb -r"%:p"
      endif
    elseif &ft == 'html' || &ft == 'xhtml'
      wa
      if !exists('b:url')
        call OpenURL(expand('%:p'))
      else
        call OpenURL(b:url)
      endif
    elseif &ft == 'vim'
      w
      if exists(':Runtime')
        return 'Runtime %'
      else
        unlet! g:loaded_{expand('%:t:r')}
        return 'source %'
      endif
    else
      wa
      if &makeprg =~ '%'
        make
      else
        make %
      endif
    endif
    return ''
  finally
    let &makeprg = old_makeprg
    let &errorformat = old_errorformat
  endtry
endfunction
command! -bar Run :execute Run()

