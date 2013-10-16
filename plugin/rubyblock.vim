" A custom text object for selecting ruby blocks.
" (https://github.com/nelstrom/vim-textobj-rubyblock)
"
" Dependences: vim-textobj-user, matchit.vim

if !exists('*textobj#user#plugin')
  finish
endif

call textobj#user#plugin('rubyblock', {
      \   '-': {
      \     '*sfile*': expand('<sfile>:p'),
      \     'select-a': 'ar',  '*select-a-function*': 's:select_a',
      \     'select-i': 'ir',  '*select-i-function*': 's:select_i'
      \   }
      \ })

let s:comment_escape = '\v^[^#]*'
let s:block_openers = '\zs(<def>|<if>|<do>|<module>|<class>)'
let s:start_pattern = s:comment_escape . s:block_openers
let s:end_pattern = s:comment_escape . '\zs<end>'
let s:skip_pattern = 'getline(".") =~ "\\w\\s\\+if"'

function! s:select_a()
  let s:flags = 'W'

  call searchpair(s:start_pattern,'',s:end_pattern, s:flags, s:skip_pattern)
  let end_pos = getpos('.')

  " Jump to match
  normal %
  let start_pos = getpos('.')

  return ['V', start_pos, end_pos]
endfunction

function! s:select_i()
  let s:flags = 'W'
  if expand('<cword>') == 'end'
    let s:flags = 'cW'
  endif

  call searchpair(s:start_pattern,'',s:end_pattern, s:flags, s:skip_pattern)

  " Move up one line, and save position
  normal k^
  let end_pos = getpos('.')

  " Move down again, jump to match, then down one line and save position
  normal j^%j
  let start_pos = getpos('.')

  return ['V', start_pos, end_pos]
endfunction

" vim:sw=2 ts=2 et fdm=marker:
