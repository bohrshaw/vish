" Description: Assistant scripts for vimrc
" Author: Bohr Shaw <pubohr@gmail.com>

" Source lines of viml
" Note that in the context of a function, `:@` is not a solution.
function! vimrc#run(type)
  let tmp = tempname()
  " When g@ calling, a:type is 'line', 'char' or 'block'.
  " In visual mode, a:type is visualmode() which is 'v', 'V', '<C-v>'.
  if a:type =~# 'line\|V'
    execute 'silent '.(a:type == 'V' ? "'<,'>" : "'[,']").'write '.tmp
  else " a:type =~# 'char\|v'
    " note `> or `] is exclusive
    execute 'silent normal! '.(a:type == 'v' ? '`<"zyv`>' : '`["zyv`]')
    call writefile(split(@z, '\n'), tmp)
  endif
  execute 'source '.tmp
  call delete(tmp)
  " the mark 'z' should be set before calling this function
  normal! g`z
endfunction

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
function! vimrc#word_frequency(...) " {{{1
  let words = split(join(getline(get(a:, 1, 1), get(a:, 2, '$'))), '\A\+')
python3 << EOF
import vim
words = {}
for word in vim.eval('words'):
    words[word] = words.get(word, 0) + 1
vim.command('return ' + str(
    [t[0]+':'+str(t[1]) for t in sorted(words.items(),
                                        key=lambda x: x[1],
                                        reverse=1)]))
EOF
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
