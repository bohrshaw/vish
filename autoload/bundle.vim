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
let s:rtp_ftdetect = [] " for sourcing ftdetect/*.vim in bundles
let s:dirs_activated = [] " for avoiding activating a bundle twice
let s:augroup_count = get(s:, 'augroup_count')

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
    let dir = split(b, '/')[-1]

    if !a:0
      let p = rtp#expand(dir)
      if isdirectory(p.'/ftdetect')
        " Don't glob and source now, as repetitive globings are quite slow
        call add(s:rtp_ftdetect, p)
      endif
    endif

    if has_key(a:trigger, 'f')
      let s:augroup_count += 1
      let aug = 'bundle'.s:augroup_count
      let bundle_cmd = 'call BundleActivate('.string(dir).', '.string(aug).')'

      execute 'augroup' aug
      execute 'autocmd' a:trigger.f =~ '[*.]' ?
            \ 'BufNewFile,BufRead '.a:trigger.f : 'FileType '.a:trigger.f
            \ bundle_cmd
      execute 'augroup END'
    else
      let bundle_cmd = 'call BundleActivate('.string(dir).')'
    endif

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
        execute 'command! -nargs=* -range -bang' c bundle_cmd '|'
              \ (c[0] == ' ' ? '<line1>,<line2>' : '').c.'<bang> <args>'
      endfor
    endif

    return 1
  endif
endfunction

" Like BundleRun, but also deal with auto-commands
function! BundleActivate(dir, ...)
  if index(s:dirs_activated, a:dir) < 0
    call s:run(a:dir)
    call add(s:dirs_activated, a:dir)
  else
    return
  endif

  " Clean any termporary autocmds, avoid recursive nesting
  if a:0
    execute 'autocmd!' a:1
  endif
  " Apply bundle specific User autocmds
  let pat = 'Bundle'.toupper(a:dir[0]).tolower(a:dir[1:])
  if exists('#User#'.pat)
    execute 'doautocmd <nomodeline> User' pat '|autocmd! User' pat
  endif
  " Apply newly defined auto-commands
  " Even if we are already in the process of a FileType autocmd, newly added
  " FileType autocmds would not be run. So run it anyway ignoring duplicates.
  doautocmd FileType
endfunction

" Inject a bundle to &rtp and source it.
" Extra arguments usally contain a timer ID.
function! BundleRun(b, ...)
  let b = s:bundle(a:b)
  if s:ifbundle(b) || b !~ '/'
    call s:run(split(b, '/')[-1])
    return 1
  endif
endfunction
command! -nargs=1 -complete=file -bar BundleRun call BundleRun(<q-args>)

" Inject a bundle to &rtp
function! BundlePath(b)
  let b = s:bundle(a:b)
  if s:ifbundle(b)
    call rtp#add(b[stridx(b,"/")+1:])
    return 1
  endif
endfunction

" Finish bundling
function! bundle#done()
  " Inject bundles from g:bundles to 'rtp'
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
if g:vundle
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
if !g:vundle
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

" Inject a directory to &rtp and source it
function! s:run(dir)
  call rtp#add(a:dir)
  let path = rtp#expand(a:dir)
  for p in [path,  path.'/after'] " source related files
    for f in glob(p.'/plugin/**/*.vim' , 1 , 1)
      execute  'source' f
    endfor
  endfor
endfunction

" Add an item to a list only if it doesn't contain the item yet
function! s:uniqadd(list, item)
  if index(a:list, a:item) < 0
    call add(a:list, a:item)
  endif
endfunction

" vim:foldmethod=expr foldexpr=getline(v\:lnum)=~#'\\v^%(fu\|if)'?'a1'\:getline(v\:lnum)=~#'^end'?'s1'\:'=':
