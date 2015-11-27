" This is the inside-of-Vim part of Vundle(the Vim bundle manager). We are
" already in the context of Vim, thus the identifer is 'bundle' instead of
" 'vundle'.
"
" Author: Bohr Shaw <pubohr@gmail.com>

" Call this function to source this file
function! bundle#init()
endfunction
let g:bundles = [] " bundles activated on startup
let g:dundles = [] " bundles to be downloaded
let s:vundle = get(g:, '_vundle') " indicate if `vundle` is running
let s:rtp_ftdetect = [] " for sourcing ftdetect/*.vim in bundles
let s:augroup_count = get(s:, 'augroup_count', 1)

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

" Lazily load a bundle (on demand loading)
" Note: Some auto-commands introduced by a bundle need to be manually triggered
" by defining a User auto-command like `autocmd User BundleFoo ...` where `Foo`
" is a capitalized bundle directory name.
function! Bundle(bundle, trigger, ...)
  if !has('vim_starting')
    return
  endif
  let b = s:bundle(a:bundle)
  if s:ifbundle(b)
    if !a:0
      let p = rtp#expand(split(b, '/')[-1])
      if isdirectory(p.'/ftdetect')
        " Don't glob and source now, as repetitive globings are quite slow
        call add(s:rtp_ftdetect, p)
      endif
    endif

    let bundle_cmd = 'call BundleRun('.string(b).')'
    if has_key(a:trigger, 'm')
      let maps = type(a:trigger.m) == 1 ? [a:trigger.m] : a:trigger.m
      " Chain user-defined mappings which has a `rhs`, like:
      "   `nnoremap <M-x> :call BundleFoo()<CR>`
      " as opposed to ones defined by a bundle, which needn't have a `rhs`:
      "   `imap <M-l>`, or just `i <M-l>`
      "   Note: Need to write `i <expr><M-l>` instead of `i <expr> <M-l>` to
      "   make pasing logic simple.
      let map_cmds = substitute(
            \ join(filter(copy(maps), 'v:val =~ ''\s\S\+\s'''), '\|'),
            \ '<', '<lt>', 'g')

      for m in maps
        let [mode, lhs] = split(m)[:1]
        let mode = split(mode, '\v%(nore)?map')[0]
        let i = match(lhs, '\v%(\<%(buffer|nowait|silent|special|script|expr|unique)\>)+\zs')
        let key = i < 0 ? lhs : strpart(lhs, i)
        let lhs = '<silent>'.lhs
        let rhs = ':<C-u>'.bundle_cmd.'\|'.map_cmds.'<CR>'
        if mode =~# '[ic!]'
          if mode =~# '[i!]'
            execute 'imap' lhs '<C-\><C-o>'.rhs.key
          endif
          if mode =~# '[c!]'
            execute 'cmap' lhs '<C-\>esetreg("z", getcmdline())[1]<CR>'.rhs.
                  \ ':<C-r>z'.key
          endif
        else
          if mode =~# 'n\|^$'
            execute 'nmap' lhs rhs.key
          endif
          if mode =~# 'x\|^$'
            execute 'xmap' lhs rhs.'gv'.key
          endif
        endif
      endfor
    endif

    if has_key(a:trigger, 'c')
      for c in type(a:trigger.c) == 1 ? [a:trigger.c] : a:trigger.c
        execute 'command! -nargs=* -bang '.c.' '.bundle_cmd.
              \ '|'.c.'<bang> <args>'
      endfor
    endif

    if has_key(a:trigger, 'f')
      let pat = a:trigger['f']
      let event_pat = pat =~ '[*.]' ?
            \ 'BufNewFile,BufRead '.pat : 'FileType '.pat
      execute 'augroup bundle'.s:augroup_count
      " Note: Be cautious about nesting auto-commands
      execute 'autocmd!' event_pat 'call BundleRun('.string(b).', 0)'
            \ '| autocmd! bundle'.s:augroup_count
      execute 'augroup END'
      let s:augroup_count += 1
    endif

    return 1
  endif
endfunction

" Inject the path of a bundle to &rtp and Load(source) it
function! BundleRun(b, ...)
  let b = s:bundle(a:b)
  if s:ifbundle(b) || b !~ '/'
    let dir = split(b, '/')[-1]
    call rtp#add(dir) " inject the bundle path to runtime path
    let path = rtp#expand(dir)
    for p in [path,  path.'/after'] " source related files
      for f in glob(p.'/plugin/**/*.vim' , 1 , 1)
        execute  'source' f
      endfor
    endfor

    " Apply auto-commands if not during Vim start-up
    if !has('vim_starting')
      " Apply bundle specific User auto-commands
      let pat = 'Bundle'.toupper(dir[0]).tolower(dir[1:])
      if exists('#User#'.pat)
        execute 'doautocmd <nomodeline> User' pat '|autocmd! User' pat
      endif
      " Apply newly defined auto-commands for most common events
      if !a:0
        doautocmd FileType
      endif
    endif

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

" Inject paths of bundles from g:bundles to 'rtp'
function! bundle#done()
  call rtp#inject('bundle', map(g:bundles, 'v:val[stridx(v:val,"/")+1:]'))

  " Source ftdetect scripts gathered in Bundle()
  augroup filetypedetect
    " Or use globpath()
    let rtp = &rtp
    let &rtp = join(s:rtp_ftdetect, ',') | runtime! ftdetect/*.vim
    let &rtp = rtp
  augroup END
endfunction

" Define local mappings for managing bundles
function! bundle#map()
  " Move between bundles
  nnoremap <buffer> <silent> ]<Tab> :call search('[BD]undle\a*(.\zs\C')<CR>
  nnoremap <buffer> <silent> [<Tab> :call search('[BD]undle\a*(.\zs\C', 'b')<CR>
  " Open a bundle's URL in the browser
  nnoremap <buffer> <silent> gX "zyi'
        \:execute 'silent Open https://github.com/'
        \.matchstr(@z, '\v-?\zs[^/]*/[^/]*')<CR>
  " Activate the bundle under the cursor line
  nnoremap <buffer><silent> <LocalLeader>b mz"zyi'
        \:call BundleRun(@z)<CR>g`z
endfunction

" Add a bundle to the list of bundles to be downloaded
if s:vundle
  function! Dundles(...)
    for b in a:000
      call s:uniqadd(g:dundles, b)
    endfor
    return 1
  endfunction
else
  function! Dundles(...)
    return 1
  endfunction
endif

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

" Determine if the bundle is enabled, or should be downloaded.
if !s:vundle
  function! s:ifbundle(b)
    if a:b[0] != '-' && !g:l || a:b[0] =~# '\u'
      return 1
    endif
  endfunction
else
  function! s:ifbundle(b)
    if a:b[0] != '-'
      call s:uniqadd(g:dundles, a:b)
      return 1
    endif
  endfunction
endif

" Add an item to a list only if it doesn't contain the item yet
function! s:uniqadd(list, item)
  if index(a:list, a:item) < 0
    call add(a:list, a:item)
  endif
endfunction

" vim:foldmethod=expr foldexpr=getline(v\:lnum)=~#'\\v^%(fu\|if)'?'a1'\:getline(v\:lnum)=~#'^end'?'s1'\:'=':
