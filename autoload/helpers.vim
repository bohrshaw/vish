" File: helpers.vim
" Author: Bohr Shaw <pubohr@gmail.com>
" Description: Small powerful tolls.

" Calculate the time spending on executing commands {{{1
function! helpers#time(commands)
  let time_start = reltime()
  exe a:commands
  let time = reltime(time_start)
  echo 'Total Seconds: ' . split(reltimestr(time))[0]
endfunction

" Count anything in a range of lines {{{1
function! helpers#count(...)
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
endfunction

" Calculate words frequency {{{1
" http://vim.wikia.com/wiki/Word_frequency_statistics_for_a_file
function! helpers#word_frequency() range
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
endfunction

" Diff with another file {{{1
function! helpers#diffWith(...)
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
endfunction

" Wipe out all unlisted buffers {{{1
function! helpers#bufffer_wipe_unlisted()
  for b in range(1, bufnr('$'))
    if bufexists(b) && ! buflisted(b)
      exe 'bw' . b
    endif
  endfor
endfunction

" Append a mode line {{{1
function! helpers#appendModeline()
  let modeline = printf(" vim:tw=%d ts=%d sw=%d et fdm=marker:", &textwidth, &shiftwidth, &tabstop)
  " Use substitute() instead of printf() to handle '%%s' modeline in LaTeX Files.
  let modeline = substitute(&commentstring, "%s", modeline, "")
  " Append a new line and a modeline at the end of file
  call append(line("$"), ["", modeline])
endfunction

" vim:tw=78 ts=2 sw=2 et fdm=marker:
