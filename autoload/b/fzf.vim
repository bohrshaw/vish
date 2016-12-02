" Mimic fzf#vim#complete#word()
function! b#fzf#dict(...)
  return fzf#vim#complete(s:extend({
    \ 'source': 'cat '.split(&dictionary, ',')[0]},
    \ get(a:000, 0, g:fzf#vim#default_layout)))
endfunction

function! s:extend(base, extra)
  let base = copy(a:base)
  if has_key(a:extra, 'options')
    let extra = copy(a:extra)
    let extra.extra_options = remove(extra, 'options')
    return extend(base, extra)
  endif
  return extend(base, a:extra)
endfunction
