function! b#ultisnips#complete()
  let snippets = UltiSnips#SnippetsInCurrentScope()
  let matches = map(keys(snippets),
        \ "{'word': v:val, 'menu': get(snippets, v:val)}")
  call complete(comp#startcol('[[:alnum:]]*'), matches)
  return ''
endfunction
