" Echo the value of an expression
function! run#eval(type)
  if a:type != 'v'
    normal! `["zyv`]
  endif
  if &filetype == 'vim'
    echo eval(@z)
  elseif &filetype =~ 'z\?sh'
    echo system(($ft == 'sh' ? 'bash' : 'zsh').' -c '.shellescape('echo '.@z))
  elseif &filetype == 'ruby'
    if has('ruby')
      execute 'ruby p' @z
    else
      echo system('ruby -e '.shellescape('p '.@z))
    endif
  elseif &filetype == 'python'
    if has('python3') || has('python')
      execute 'python'.(has('python3')?'3':'') 'print('.@z.')'
    else
      echo system('python'.(executable('python3')?'3':'').' -c '.
            \ shellescape('print('.@z.')'))
    endif
  elseif &filetype == 'lua'
    if has('lua')
      execute 'lua print('.@z.')'
    else
      echo system('lua -e '.shellescape('print('.@z.')'))
    endif
  endif
endfunction
