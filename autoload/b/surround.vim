function! b#surround#()
  let k = v#getchar()
  if empty(k)
    return ''
  endif
  let pair = has_key(g:surround_pairs, k) ? g:surround_pairs[k] : k.k
  return pair.repeat(
        \ mode()[0] == 'c' ? "\<Left>" : "\<C-g>U\<Left>", len(pair)/2)
endfunction

let g:surround_pairs = {
      \ '(': '(  )', ')': '()', 'b': '()',
      \ '[': '[  ]', ']': '[]', 'r': '[]',
      \ '{': '{  }', '}': '{}', 'B': '{}',
      \ '<': '<>', '>': '<>', 'a': '<>',
      \ 's': '``',
      \ "\<M-9>": '((  ))',
      \ "\<M-[>": '[[  ]]',
      \ "\<M-'>": "''''''",
      \ "\<M-">": '""""""', "\<M-\">": '""""""',
      \ "~": '``````',
      \ "\<M-8>": '****',
      \ "\<M-->": '____',
      \ }
