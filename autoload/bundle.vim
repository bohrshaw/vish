" bundle.vim - a Vim bundle manager
" Author: Bohr Shaw <pubohr@gmail.com>

function! bundle#init()
  " Define an auto-group for bundle activation
  execute 'augroup bundling | augroup END'
  let g:bundles = [] " bundles activated on startup
  let g:dundles = [] " bundles to be downloaded
endfunction

function! Bundle(...)
  if s:bundle_enabled(a:1)
    let dirs = map(add((has_key(a:2, 'd') ? a:2['d'] : []), a:1),
          \ 'matchstr(v:val, ''/\zs.*'')')
    let bundle_cmd = 'call call("BundleRun",'.string(dirs).')'
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
      " One time autocmd
      execute 'autocmd bundling '.event_pat.' '.bundle_cmd.
            \ '|autocmd! bundling '.event_pat
    endif
    return 1
  endif
endfunction

function! BundleRun(...)
  for dir in a:000
    if path#add(dir) " inject the bundle path to runtime path
      let path = expand('~/.vim/bundle/'.dir)
      for p in [path,  path.'/after'] " source related files
        for d in ['ftdetect', 'plugin']
          for f in glob(p.'/'.d.'/*.vim',1,1)
            execute  filereadable(f) ? 'source '.f : ''
          endfor
        endfor
      endfor
    endif
  endfor
endfunction

function! BundlePath(b)
  if s:bundle_enabled(a:b)
    call path#add(a:b[stridx(a:b,"/")+1:])
    return 1
  endif
endfunction

function! Bundles(...)
  for b in a:000
    if s:bundle_enabled(b)
      call s:uniqadd(g:bundles, b)
      let if_config = 1
    endif
  endfor
  return get(l:, 'if_config') ? 1 : 0
endfunction

function! Dundles(...)
  for b in a:000
    call s:uniqadd(g:dundles, b)
  endfor
  return 1
endfunction

function! s:bundle_enabled(b)
  if a:b[0] == '-'
    return
  endif
  call s:uniqadd(g:dundles, a:b) " add a bundle to the bundle downloading list
  if a:b[0] =~# '\u' || !get(g:, 'l')
    return 1
  endif
endfunction

function! s:uniqadd(list, item)
  if index(a:list, a:item) < 0
    call add(a:list, a:item)
  endif
endfunction

" Inject bundle paths to 'rtp'
command! BundleInject call path#inject('bundle',
      \ map(g:bundles, 'v:val[stridx(v:val,"/")+1:]'))
