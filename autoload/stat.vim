" Count anything in a range of lines
function! stat#count(...)
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

" Calculate words frequency
" http://vim.wikia.com/wiki/Word_frequency_statistics_for_a_file
function! stat#word_frequency(...)
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
endfunction

