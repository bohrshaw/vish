" rtp.vim - runtime path manager (based on 'pathogen')
" Author: Bohr Shaw <pubohr@gmail.com>

" For each directory in the runtime path, add a second entry with the given
" argument appended. If the argument ends in '/*', add a separate entry for
" each subdirectory. For example, an argument 'bundle/*' makes .vim/bundle/*,
" $VIM/vimfiles/bundle/*, $VIMRUNTIME/bundle/*, $VIM/vimfiles/bundle/*/after,
" and .vim/bundle/*/after be added (on UNIX).  If the second argument is a
" list, add a separate entry for each item in the list.
function! rtp#inject(...) abort
  let bundle_base = a:0 ? a:1 : 'bundle/*'
  let dirs = []
  for dir in rtp#split(&rtp)
    if dir =~# '\<after$'
      if exists('a:2') && type(a:2) == 3
        let base_dir = substitute(dir, 'after$', a:1, '')
        if isdirectory(base_dir)
          let subdirs = filter(map(copy(a:2), 'base_dir."/".v:val."/after"'), 'isdirectory(v:val)')
        else
          continue
        endif
      elseif bundle_base =~# '\*$'
        let subdirs = filter(path#glob_directories(substitute(dir,'after$',bundle_base[0:-2],'').'*/after'), '!rtp#is_disabled(v:val[0:-7])')
      else
        let subdirs = [substitute(dir, 'after$', '', '') . bundle_base . '/after']
      endif
      let dirs += subdirs + [dir]
    else
      if exists('a:2') && type(a:2) == 3
        let subdirs = isdirectory(dir.'/'.a:1) ? map(copy(a:2), 'dir."/".a:1."/".v:val') : []
      elseif bundle_base =~# '\*$'
        let subdirs = filter(path#glob_directories(dir.'/'.bundle_base[0:-2].'*'), '!rtp#is_disabled(v:val)')
      else
        let subdirs = [dir . '/' . bundle_base]
      endif
      let dirs += [dir] + subdirs
    endif
  endfor
  if has('win32') && !&shellslash
    execute 'let dirs = '.substitute(string(dirs),'/','\\','g')
  endif
  let &rtp = rtp#join(dirs)
  return 1
endfunction

" Prepend the given directory to the runtime path and append its corresponding
" 'after' directory. If the directory is already included, move it to the
" outermost position. Wildcards are added as is. Ending a path in /* causes
" all subdirectories to be added (except those in g:path_disabled).
function! rtp#surround(path) abort
  let rtp = rtp#split(&rtp)
  if a:path =~# '[\/]\*$'
    let path = fnamemodify(a:path[0:-4], ':p:s?[\/]\=$??')
    let before = filter(path#glob_directories(path.'/*'), '!rtp#is_disabled(v:val)')
    let after = filter(reverse(path#glob_directories(path."/*/after")), '!rtp#is_disabled(v:val[0:-7])')
    call filter(rtp,'v:val[0:strlen(path)-1] !=# path')
  else
    let path = fnamemodify(a:path, ':p:s?[\/]\=$??')
    let before = [path]
    let after = [path . '/after']
    call filter(rtp, 'index(before + after, v:val) == -1')
  endif
  let &rtp = rtp#join(before, rtp, after)
  return &rtp
endfunction

" Add paths of a bundle to runtime path
function! rtp#add(dir)
  let path = rtp#expand(a:dir)
  let rtp = rtp#split(&rtp)
  if index(rtp, path) < 0
    call insert(rtp, path, 1)
    let path_after = path.'/after'
    if isdirectory(path_after)
      call insert(rtp, path_after, -1)
    endif
    let &rtp = rtp#join(rtp)
  endif
  return 1
endfunction

" Invoke :helptags on all non-$VIMRUNTIME doc directories in runtimepath.
function! rtp#helptags(...) abort
  for dir in rtp#split(&rtp)
    let dir = expand(dir.'/doc/')
    if filewritable(dir) == 2 &&
          \ strpart(dir, 0, strlen($VIMRUNTIME)) !=# $VIMRUNTIME &&
          \ (!filereadable(dir.'tags') || get(a:, 1) == 1)
      silent! execute 'helptags' fnameescape(dir)
    endif
  endfor
endfunction
command! -bar -bang Helptags call rtp#helptags(<bang>0)

" Check if a bundle is disabled. A bundle is considered disabled if it ends in
" a tilde or its basename or full name is included in the list
" g:path_disabled.
function! rtp#is_disabled(path)
  if a:path =~# '\~$'
    return 1
  elseif !exists("g:path_disabled")
    return 0
  endif
  let blacklist = g:path_disabled
  return index(blacklist, strpart(a:path, strridx(a:path, '/')+1)) != -1 && index(blacklist, a:path) != 1
endfunction

" Split a path into a list.
function! rtp#split(path) abort
  if type(a:path) == type([]) | return a:path | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction

" Convert a list to a path.
function! rtp#join(...) abort
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
endfunction

" Expand a directory or path to full-path
function! rtp#expand(dir)
  return expand(a:dir[:1] =~ '[/\\~:]' ? a:dir : $MYVIM.'/bundle/'.a:dir)
endfunction

" vim:et sw=2 foldmethod=expr foldexpr=getline(v\:lnum)=~#'^fu'?'a1'\:getline(v\:lnum)=~#'^endf'?'s1'\:'=':
