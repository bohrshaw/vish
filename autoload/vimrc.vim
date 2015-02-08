" Description: Assistant scripts for vimrc
" Author: Bohr Shaw <pubohr@gmail.com>

" Execute lines of viml, or echo the value of a viml expression
function! vimrc#run(type)
  " When g@ calling, a:type is 'line', 'char' or 'block'.
  " In visual mode, a:type is visualmode().
  if a:type =~# 'line\|V'
    execute 'silent '.(a:type == 'V' ? "'<,'>" : "'[,']").'yank z'
    " join breaked lines before executing
    let @z = substitute(@z, '\n\s*\\', '', 'g')
    @z
  else " a:type =~# 'char\|v'
    " note `> or `] is exclusive
    execute 'silent normal! '.(a:type == 'v' ? '`<"zyv`>' : '`["zyv`]')
    try
      echo eval(@z)
    catch
      echohl Error | echo "Invalid expression" | echohl None
    endtry
  endif
  " the mark 'z' should be set before calling this function
  normal! g`z
endfunction

" Create a path conveniently
function! vimrc#mkdir(...) " {{{1
  let dir = fnamemodify(expand(a:0 || empty(a:1) ? '%:h' : a:1), ':p')
  try
    call mkdir(dir, 'p')
    echo "Succeed in creating directory: " . dir
  catch
    echohl WarningMsg | echo "Fail in creating directory: " . dir | echohl NONE
  endtry
endfunction " }}}1

" Count anything in a range of lines
function! vimrc#count(...) " {{{1
  if a:0 == 3
    let range = a:2 . ',' . a:3
  elseif a:0 == 2
    let range = a:1 . ',' . a:2
  else
    let range = '%'
  endif

  redir => subscount
  silent exe range . 's/' . (a:0 == 0 ? '' : a:1) . '//gne'
  redir END

  let result = matchstr(subscount, '\d\+')
  return result == "" ? 0 : result
endfunction " }}}1

" Do something for all files in the quickfix list or a location list
function! vimrc#errdo(list, cmd) " {{{1
  let pre = -1
  for e in a:list == 'q' ? getqflist() : getloclist()
    let cur = e['bufnr']
    if cur != pre
      execute 'silent buffer '.cur.'|silent! '.a:cmd
    endif
    let pre = cur
  endfor
endfunction " }}}1

" Calculate words frequency
" http://vim.wikia.com/wiki/Word_frequency_statistics_for_a_file
function! vimrc#word_frequency() range " {{{1
  let all = split(join(getline(a:firstline, a:lastline)), '\A\+')
  let frequencies = {}
  for word in all
    let frequencies[word] = get(frequencies, word, 0) + 1
  endfor
  new
  setlocal buftype=nofile bufhidden=hide noswapfile tabstop=20
  for [key,value] in items(frequencies)
    call append('$', key."\t".value)
  endfor
  sort i
endfunction " }}}1

" Diff with another file
function! vimrc#diffwith(...) " {{{1
  let filetype=&ft
  tab sp
  diffthis
  " Diff with the current saved state.
  if a:0 == 0
    vnew | exe "setl bt=nofile bh=wipe nobl ft=" . filetype
    r # | 1del
    " Diff with another file.
  else
    exe "vsp " . a:1
  endif
  diffthis
  wincmd p
endfunction " }}}1

" Wipe out all unlisted buffers
function! vimrc#bufffer_wipe_unlisted() " {{{1
  for b in range(1, bufnr('$'))
    if bufexists(b) && ! buflisted(b)
      exe 'bw' . b
    endif
  endfor
endfunction " }}}1

" vim:tw=80 ts=2 sw=2 et fdm=marker:
