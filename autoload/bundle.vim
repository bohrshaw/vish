" This is the inside-of-Vim part of Vundle(the Vim bundle manager). We are
" already in the context of Vim, thus the identifer is 'bundle' instead of
" 'vundle'.
"
" Author: Bohr Shaw <pubohr@gmail.com>

" Call this function to source this file
function! bundle#init()
  let g:bundles = [] " bundles activated on startup
  let g:dundles = [] " bundles to be downloaded
endfunction

" Populate the list: g:bundles
function! Bundles(...)
  for b in a:000
    if s:ifbundle(b)
      call s:uniqadd(g:bundles, s:bundle(b))
      let if_config = 1
    endif
  endfor
  return get(l:, 'if_config') ? 1 : 0
endfunction
" Inject paths of bundles from g:bundles to 'rtp'
command! BundleInject call rtp#inject('bundle',
      \ map(g:bundles, 'v:val[stridx(v:val,"/")+1:]'))

" Load bundle on demands.
" Note: Auto-commands may not be executed until e.g. the file is reedited.
function! Bundle(...)
  let b = s:bundle(a:1)
  if s:ifbundle(b)
    let bundle_cmd = 'call BundleRun('.string(b).')'
    if has_key(a:2, 'm')
      " Get all user-defined mapping commands
      let map_cmds = substitute(
            \ join(filter(copy(a:2['m']), 'v:val =~ ''\s\S\+\s'''), '\|'),
            \ '<', '<lt>', 'g')
      for map in a:2['m']
        let key = split(map)[1]
        let map_key = map[0].'map <silent> '.key.' '
        let map_activate = ':<C-U>'.bundle_cmd.
              \ '\|doautocmd FileType\|'.map_cmds.'<CR>'
        if map =~# '^[ic]\|^\a\{-}!'
          execute map_key.'<Esc>'.map_activate.'a'.key
        else
          execute map_key.map_activate.key
          if map =~# '^no'
            execute 'xmap '.key.' '.map_activate.key
          endif
        endif
      endfor
    end
    if has_key(a:2, 'c')
      let cmd = a:2['c']
      execute 'command! '.cmd.' '.bundle_cmd.'|'.cmd
    endif
    if has_key(a:2, 'f')
      let pat = a:2['f']
      let event_pat = pat =~ '[*.]' ?
            \ 'BufNewFile,BufReadPre '.pat : 'FileType '.pat
      execute 'augroup bundle'.s:augroup_count.'|augroup END'
      execute 'autocmd bundle'.s:augroup_count event_pat bundle_cmd
            \ '|autocmd! bundle'.s:augroup_count
      let s:augroup_count += 1
    endif
    return 1
  endif
endfunction
let s:augroup_count = get(s:, 'augroup_count', 1)

" Inject the path of a bundle to &rtp and Load(source) it
function! BundleRun(b)
  let b = s:bundle(a:b)
  if s:ifbundle(b) || b !~ '/'
    let dir = split(b, '/')[-1]
    call rtp#add(dir) " inject the bundle path to runtime path
    let path = rtp#expand(dir)
    for p in [path,  path.'/after'] " source related files
      for d in ['ftdetect', 'plugin']
        for f in glob(p.'/'.d.'/**/*.vim',1,1)
          execute  filereadable(f) ? 'source '.f : ''
        endfor
      endfor
    endfor
    return 1
  endif
endfunction
command! -nargs=1 -complete=file -bar BundleRun call BundleRun(<q-args>)

" Inject the path of a bundle to &rtp
function! BundlePath(b)
  let b = s:bundle(a:b)
  if s:ifbundle(b)
    call rtp#add(b[stridx(b,"/")+1:])
    return 1
  endif
endfunction

" Add a bundle to the list of bundles to be downloaded
function! Dundles(...)
  for b in a:000
    call s:uniqadd(g:dundles, b)
  endfor
  return 1
endfunction

" Return the bundle with the branch part cut off
function! s:bundle(b)
  if a:b =~ ':'
    if a:b[-1:] == ':'
      return a:b[:-2]
    endif
    let [repo, other] = split(a:b, ':')
    return repo . matchstr(other, '/.*')
  endif
  return a:b
endfunction

" Determine if the bundle is enabled. Otherwise, it also won't be downloaded.
function! s:ifbundle(b)
  if a:b[0] == '-'
    return
  endif
  call s:uniqadd(g:dundles, a:b) " add a bundle to the bundle downloading list
  if a:b[0] =~# '\u' || !get(g:, 'l')
    return 1
  endif
endfunction

" Add an item to a list only if it doesn't contain the item yet
function! s:uniqadd(list, item)
  if index(a:list, a:item) < 0
    call add(a:list, a:item)
  endif
endfunction

" vim:foldmethod=expr foldexpr=getline(v\:lnum)=~#'^fu'?'a1'\:getline(v\:lnum)=~#'^endf'?'s1'\:'=':
