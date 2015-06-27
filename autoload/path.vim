" path.vim - runtime path manager (based on 'pathogen')
" Author: Bohr Shaw <pubohr@gmail.com>

" For each directory in the runtime path, add a second entry with the given
" argument appended. If the argument ends in '/*', add a separate entry for
" each subdirectory. For example, an argument 'bundle/*' makes .vim/bundle/*,
" $VIM/vimfiles/bundle/*, $VIMRUNTIME/bundle/*, $VIM/vimfiles/bundle/*/after,
" and .vim/bundle/*/after be added (on UNIX).  If the second argument is a
" list, add a separate entry for each item in the list.
function! path#inject(...) abort " {{{1
  let bundle_base = a:0 ? a:1 : 'bundle/*'
  let dirs = []
  for dir in path#split(&rtp)
    if dir =~# '\<after$'
      if exists('a:2') && type(a:2) == 3
        let base_dir = substitute(dir, 'after$', a:1, '')
        if isdirectory(base_dir)
          let subdirs = filter(map(copy(a:2), 'base_dir."/".v:val."/after"'), 'isdirectory(v:val)')
        else
          continue
        endif
      elseif bundle_base =~# '\*$'
        let subdirs = filter(path#glob_directories(substitute(dir,'after$',bundle_base[0:-2],'').'*/after'), '!path#is_disabled(v:val[0:-7])')
      else
        let subdirs = [substitute(dir, 'after$', '', '') . bundle_base . '/after']
      endif
      let dirs += subdirs + [dir]
    else
      if exists('a:2') && type(a:2) == 3
        let subdirs = isdirectory(dir.'/'.a:1) ? map(copy(a:2), 'dir."/".a:1."/".v:val') : []
      elseif bundle_base =~# '\*$'
        let subdirs = filter(path#glob_directories(dir.'/'.bundle_base[0:-2].'*'), '!path#is_disabled(v:val)')
      else
        let subdirs = [dir . '/' . bundle_base]
      endif
      let dirs += [dir] + subdirs
    endif
  endfor
  if has('win32') && !&shellslash
    execute 'let dirs = '.substitute(string(dirs),'/','\\','g')
  endif
  let &rtp = path#join(dirs)
  return 1
endfunction
" }}}1

" Prepend the given directory to the runtime path and append its corresponding
" 'after' directory. If the directory is already included, move it to the
" outermost position. Wildcards are added as is. Ending a path in /* causes
" all subdirectories to be added (except those in g:path_disabled).
function! path#surround(path) abort " {{{1
  let rtp = path#split(&rtp)
  if a:path =~# '[\/]\*$'
    let path = fnamemodify(a:path[0:-4], ':p:s?[\/]\=$??')
    let before = filter(path#glob_directories(path.'/*'), '!path#is_disabled(v:val)')
    let after = filter(reverse(path#glob_directories(path."/*/after")), '!path#is_disabled(v:val[0:-7])')
    call filter(rtp,'v:val[0:strlen(path)-1] !=# path')
  else
    let path = fnamemodify(a:path, ':p:s?[\/]\=$??')
    let before = [path]
    let after = [path . '/after']
    call filter(rtp, 'index(before + after, v:val) == -1')
  endif
  let &rtp = path#join(before, rtp, after)
  return &rtp
endfunction " }}}1

" Add paths of a bundle to runtime path
function! path#add(dir) " {{{1
  let path = expand(a:dir !~ '[/\\]' ? '~/.vim/bundle/'.a:dir : a:dir)
  let rtp = path#split(&rtp)
  if index(rtp, 'path') < 0
    call insert(rtp, path, 1)
    let path_after = path.'/after'
    if isdirectory(path_after)
      call insert(rtp, path_after, -1)
    endif
    let &rtp = path#join(rtp)
    return 1
  endif
endfunction " }}}1

" Invoke :helptags on all non-$VIM doc directories in runtimepath.
function! path#helptags() abort " {{{1
  for glob in path#split(&rtp)
    for dir in split(glob(glob), "\n")
      if (dir.'/')[0 : strlen($VIMRUNTIME)] !=# $VIMRUNTIME.'/' && filewritable(dir.'/doc') == 2 && !empty(filter(split(glob(dir.'/doc/*'),"\n>"),'!isdirectory(v:val)')) && (!filereadable(dir.'/doc/tags') || filewritable(dir.'doc/tags'))
        silent! execute 'helptags' fnameescape(dir.'/doc')
      endif
    endfor
  endfor
endfunction

command! -bar Helptags :call path#helptags()
" }}}1

" Return a directory list based on a glob pattern.
function! path#glob_directories(pattern) abort " {{{1
  return filter(split(glob(a:pattern),"\n"), 'isdirectory(v:val)')
endfunction "}}}1

" Check if a bundle is disabled. A bundle is considered disabled if it ends in
" a tilde or its basename or full name is included in the list
" g:path_disabled.
function! path#is_disabled(path) " {{{1
  if a:path =~# '\~$'
    return 1
  elseif !exists("g:path_disabled")
    return 0
  endif
  let blacklist = g:path_disabled
  return index(blacklist, strpart(a:path, strridx(a:path, '/')+1)) != -1 && index(blacklist, a:path) != 1
endfunction "}}}1

" Split a path into a list.
function! path#split(path) abort " {{{1
  if type(a:path) == type([]) | return a:path | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction " }}}1

" Convert a list to a path.
function! path#join(...) abort " {{{1
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

" vim:et sw=2 fdm=marker:
