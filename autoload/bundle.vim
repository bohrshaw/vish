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
            \ '<\ze\w[^-]', '<lt>', 'g')
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
          for f in glob(p.'/'.d.'/*',1,1)
            execute  filereadable(f) ? 'source '.f : ''
          endfor
        endfor
      endfor
    endif
  endfor
endfunction

function! Bundles(...)
  for bd in a:000
    let b = type(bd) == 3 ? bd[0] : bd
    let is_enabled = b[0] == '+'
    if b[0] != '-' && (!get(g:, 'l') || is_enabled)
      call add(g:bundles, is_enabled ? b[1:] : b)
      if type(bd) == 3 " bundle dependencies
        for d in bd[1:]
          if index(g:bundles, d) < 0
            call add(g:bundles, d)
          endif
        endfor
      endif
      let if_config = 1
    endif
    unlet bd " allow bd to hold a different type at the next loop
  endfor
  return get(l:, 'if_config') ? 1 : 0
endfunction

" Inject bundle paths to 'rtp'
command! BundleDone call path#inject('bundle',
      \ map(g:bundles, 'v:val[stridx(v:val,"/")+1:]'))
