" bundle.vim - a Vim bundle manager
" Author: Bohr Shaw <pubohr@gmail.com>

" Define an auto-group for bundle activation
augroup bundling
augroup END

let g:bundles = [] " on-Vim-startup bundles
let g:dundles = [] " on-demand bundles

function! Bundle(...)
  let for_light = a:1[0] == '+'
  if !get(g:, 'l') || for_light
    call add(g:dundles, a:1)
    let dirs = map((has_key(a:2, 'd')?a:2['d']:[])+[for_light?a:1[1:]:a:1],
          \ 'matchstr(v:val, ''/\zs.*'')')
    let bundle_cmd = 'call call("BundleActivate",'.string(dirs).')'
    if has_key(a:2, 'm')
      " Get all user-defined mapping commands
      let map_cmds = substitute(
            \ join(filter(copy(a:2['m']), 'v:val =~ ''\s\S\+\s'''), '\|'),
            \ '<', '<lt>', 'g')
      for map in a:2['m']
        let key = split(map)[1]
        let map_key = map[0].'map <silent> '.key.' '
        let map_activate = ':<C-U>'.bundle_cmd.'\|'.map_cmds.'<CR>'
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
      execute 'autocmd bundling '.event_pat.' '.bundle_cmd.
            \ '|autocmd! bundling '.event_pat
    endif
    return 1
  endif
endfunction

function! BundleActivate(...)
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

function! BundleNow(b)
  let is_enabled = a:b[0] == '+'
  let b = is_enabled ? a:b[1:] : a:b
  if !get(g:, 'l') && a:b[0] != '-' || is_enabled
    call path#add(b[stridx(b,"/")+1:])
    call add(g:dundles, b)
    return 1
  endif
endfunction

function! Bundles(...)
  for b in a:000
    let is_enabled = b[0] == '+'
    if is_enabled
      let b = b[1:]
    endif
    if !get(g:, 'l') && b[0] != '-' || is_enabled
      if index(g:bundles, b) < 0
        call add(g:bundles, b)
      endif
      let if_config = 1
    endif
  endfor
  return get(l:, 'if_config') ? 1 : 0
endfunction

" Inject bundle paths to 'rtp'
command! BundleDone call path#inject('bundle',
      \ map(g:bundles, 'v:val[stridx(v:val,"/")+1:]'))
