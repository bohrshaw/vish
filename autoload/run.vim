" Source lines of Viml
" Note: In the context of a function, `:@` is not a solution.
function! run#viml(type)
  " Note: 'path' must match an autoload function name; 'file' may not yet exists.
  let file = matchstr(fnamemodify(bufname(''), ':p'), '\v<autoload[/\\]\zs.*|[^/\\]*$')
  let path = s:tmpdir.'/'.file
  if file =~ '[/\\]'
    call mkdir(fnamemodify(path, ':h'), 'p')
  endif
  " When called by `g@`, a:type is 'line', 'char' or 'block'.
  " In visual mode, a:type is visualmode() which is 'v', 'V', '<C-v>'.
  " Note: :silent! to suppress warning of an existing swap file.
  if a:type =~# 'line\|V'
    execute 'silent! keepalt '.
          \(a:type == 'V' ? "'<,'>" : "'[,']").'write! '.path
  else " a:type =~# 'char\|v'
    " Note: `> or `] is exclusive.
    execute 'silent normal! '.(a:type == 'v' ? '`<"zyv`>' : '`["zyv`]')
    keepalt call writefile(split(@z, '\n'), path)
  endif
  execute 'source' path
  " call delete(path) " will be deleted upon Vim exit, due to tempname()
  " The mark 'z' should be set before calling this function
  normal! g`z
endfunction
let s:tmpdir = fnamemodify(tempname(), ':h')

function! run#map()
  nnoremap <buffer><silent> R mz:set operatorfunc=run#viml<CR>g@
  " use :normal to support mapping count
  nmap <buffer><silent> Rr :normal RVl<CR>
  nnoremap <buffer> RR :source %<CR>
  nnoremap <buffer><expr> R% ':'.(g:loaded_scriptease?'Runtime':'source %').'<CR>'
  xnoremap <buffer><silent> R mz:<C-U>call run#viml(visualmode())<CR>
endfunction

" Echo the value of an expression
function! run#eval(type)
  if &filetype == 'markdown'
    execute (a:type == 'v' ? "'<,'>" : "'[,']").'Preview'
    return
  endif
  if a:type != 'v'
    normal! `["zyv`]
  endif
  if &filetype == 'vim'
    " Should evaluate in the global scope as un-prefixed variables default to
    " the function local scope here.
    doautocmd <nomodeline> User VimEval
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

augroup vim_eval
  autocmd!
  autocmd User VimEval echo eval(@z)
augroup END
