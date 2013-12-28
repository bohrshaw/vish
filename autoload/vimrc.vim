" Description: Assistant scripts for vimrc
" Author: Bohr Shaw <pubohr@gmail.com>

" Create a path conveniently
function! vimrc#mkdir(...) " {{{1
  if a:1 =~ '\v^(/|(\~|\w:)[\/])'
    let dir = expand(a:1)
  else
    let dir = getcwd() . "/" . (a:0 == 0 ? expand('%:h') : a:1)
  endif
  call mkdir(dir, 'p')
endfunction " }}}1

" Calculate the time spending on executing commands
function! vimrc#time(commands) " {{{1
  let time_start = reltime()
  exe a:commands
  let time = reltime(time_start)
  echo 'Total Seconds: ' . split(reltimestr(time))[0]
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

" Append a mode line
function! vimrc#appendModeline() " {{{1
  let modeline = printf(" vim:tw=%d ts=%d sw=%d et fdm=marker:", &textwidth, &shiftwidth, &tabstop)
  " Use substitute() instead of printf() to handle '%%s' modeline in LaTeX Files.
  let modeline = substitute(&commentstring, "%s", modeline, "")
  " Append a new line and a modeline at the end of file
  call append(line("$"), ["", modeline])
endfunction " }}}1

" vim:tw=80 ts=2 sw=2 et fdm=marker:
