" pathing.vim - runtime path manager (based on 'pathogen')
" Author: Bohr Shaw <pubohr@gmail.com>

" Install in ~/.vim/autoload.
"
" For management of individually installed plugins in ~/.vim/bundle, adding
" `call pathing#setout()` to the top of your .vimrc is the only other setup
" necessary.

if exists("g:loaded_pathing") || &cp
  finish
endif
let g:loaded_pathing = 1

" The point of entry for basic default usage. Give a relative path(a single
" folder) to invoke pathing#circle() (defaults to 'bundle/*'), or an absolute
" path to invoke pathing#surround().
function! pathing#setout(...) abort " {{{1
  for path in a:0 ? reverse(copy(a:000)) : ['bundle/*']
    " Remove a trailing slash if existing
    let path = substitute(path, '[\/]$', '', '')
    " A relative path
    if path =~# '\v^[^\/]+([\/]\*)?$'
      call pathing#circle(path)
    " Assume a absolute path
    else
      call pathing#surround(path)
    endif
  endfor
  return ''
endfunction " }}}1

" For each directory in the runtime path, add a second entry with the given
" argument appended. If the argument ends in '/*', add a separate entry for
" each subdirectory. The default argument is 'bundle/*', which means that
" .vim/bundle/*, $VIM/vimfiles/bundle/*, $VIMRUNTIME/bundle/*,
" $VIM/vimfiles/bundle/*/after, and .vim/bundle/*/after will be added (on
" UNIX).
function! pathing#circle(...) abort " {{{1
  let name = a:0 ? a:1 : 'bundle/*'
  let list = []
  for dir in pathing#split(&rtp)
    if dir =~# '\<after$'
      if name =~# '\*$'
        let list += filter(pathing#glob_directories(substitute(dir,'after$',name[0:-2],'').'*/after'), '!pathing#is_disabled(v:val[0:-7])') + [dir]
      else
        let list += [dir, substitute(dir, 'after$', '', '') . name . '/after']
      endif
    else
      if name =~# '\*$'
        let list += [dir] + filter(pathing#glob_directories(dir.'/'.name[0:-2].'*'), '!pathing#is_disabled(v:val)')
      else
        let list += [dir . '/' . name, dir]
      endif
    endif
  endfor
  let &rtp = pathing#join(pathing#uniq(list))
  return 1
endfunction
" }}}1

" Prepend the given directory to the runtime path and append its corresponding
" 'after' directory. If the directory is already included, move it to the
" outermost position. Wildcards are added as is. Ending a path in /* causes
" all subdirectories to be added (except those in g:pathing_disabled).
function! pathing#surround(path) abort " {{{1
  let rtp = pathing#split(&rtp)
  if a:path =~# '[\/]\*$'
    let path = fnamemodify(a:path[0:-4], ':p:s?[\/]\=$??')
    let before = filter(pathing#glob_directories(path.'/*'), '!pathing#is_disabled(v:val)')
    let after = filter(reverse(pathing#glob_directories(path."/*/after")), '!pathing#is_disabled(v:val[0:-7])')
    call filter(rtp,'v:val[0:strlen(path)-1] !=# path')
  else
    let path = fnamemodify(a:path, ':p:s?[\/]\=$??')
    let before = [path]
    let after = [path . '/after']
    call filter(rtp, 'index(before + after, v:val) == -1')
  endif
  let &rtp = pathing#join(before, rtp, after)
  return &rtp
endfunction " }}}1

" Invoke :helptags on all non-$VIM doc directories in runtimepath.
function! pathing#helptags() abort " {{{1
  for glob in pathing#split(&rtp)
    for dir in split(glob(glob), "\n")
      if (dir.'/')[0 : strlen($VIMRUNTIME)] !=# $VIMRUNTIME.'/' && filewritable(dir.'/doc') == 2 && !empty(filter(split(glob(dir.'/doc/*'),"\n>"),'!isdirectory(v:val)')) && (!filereadable(dir.'/doc/tags') || filewritable(dir.'doc/tags'))
        silent! execute 'helptags' pathing#fnameescape(dir.'/doc')
      endif
    endfor
  endfor
endfunction

command! -bar Helptags :call pathing#helptags()
" }}}1

" Return a directory list based on a glob pattern.
function! pathing#glob_directories(pattern) abort " {{{1
  return filter(split(glob(a:pattern),"\n"), 'isdirectory(v:val)')
endfunction "}}}1

" Check if a bundle is disabled. A bundle is considered disabled if it ends in
" a tilde or its basename or full name is included in the list
" g:pathing_disabled.
function! pathing#is_disabled(path) " {{{1
  if a:path =~# '\~$'
    return 1
  elseif !exists("g:pathing_disabled")
    return 0
  endif
  let blacklist = g:pathing_disabled
  return index(blacklist, strpart(a:path, strridx(a:path, '/')+1)) != -1 && index(blacklist, a:path) != 1
endfunction "}}}1

" Split a path into a list.
function! pathing#split(path) abort " {{{1
  if type(a:path) == type([]) | return a:path | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction " }}}1

" Convert a list to a path.
function! pathing#join(...) abort " {{{1
  if type(a:1) == type(1) && a:1
    let i = 1
    let space = ' '
  else
    let i = 0
    let space = ''
  endif
  let path = ""
  while i < a:0
    if type(a:000[i]) == type([])
      let list = a:000[i]
      let j = 0
      while j < len(list)
        let escaped = substitute(list[j],'[,'.space.']\|\\[\,'.space.']\@=','\\&','g')
        let path .= ',' . escaped
        let j += 1
      endwhile
    else
      let path .= "," . a:000[i]
    endif
    let i += 1
  endwhile
  return substitute(path,'^,','','')
endfunction " }}}1

" Remove duplicates from a list.
function! pathing#uniq(list) abort " {{{1
  let i = 0
  let seen = {}
  while i < len(a:list)
    if (a:list[i] ==# '' && exists('empty')) || has_key(seen,a:list[i])
      call remove(a:list,i)
    elseif a:list[i] ==# ''
      let i += 1
      let empty = 1
    else
      let seen[a:list[i]] = 1
      let i += 1
    endif
  endwhile
  return a:list
endfunction " }}}1

" vim:et sw=2 fdm=marker:

