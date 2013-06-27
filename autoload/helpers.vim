" File: helpers.vim
" Author: Bohr Shaw(pubohr@gmail.com)
" Description: Small powerful tolls.

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

" Append a mode line {{{1
function! helpers#appendModeline()
  let modeline = printf(" vim:tw=%d ts=%d sw=%d et fdm=marker:", &textwidth, &shiftwidth, &tabstop)
  " Use substitute() instead of printf() to handle '%%s' modeline in LaTeX Files.
  let modeline = substitute(&commentstring, "%s", modeline, "")
  " Append a new line and a modeline at the end of file
  call append(line("$"), ["", modeline])
endfunction

"}}}1

" vim:tw=78 ts=2 sw=2 et fdm=marker:
