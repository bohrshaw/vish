" Depend on `git` related bundles like "vim-fugitive".

let s:fugisid = "<SNR>".scriptease#scriptid(resolve(globpath(&rtp,
      \ 'plugin/fugitive.vim')))

function! git#run(...)
  let batch = a:0 > 0 ? 1 : 0
  let s = ''
  while 1
    let c = v#getchar()
    if c == "\<BS>"
      let s = s[:-2] | continue
    elseif c =~ "[ ;\<CR>]"
      if c == ' ' && !batch
        let batch = 1 | continue
      endif
      break
    elseif c == ''
      return
    endif
    let s .= c
    if !batch && exists('g:git_cmds["'.s.'"]')
      break
    endif
  endwhile
  let end = len(s)-1
  let [i, j, cmds] = [0, end, []]
  while i <= j
    while j >= i
      let c = s[i : j]
      if exists('g:git_cmds["'.c.'"]')
        call add(cmds, c)
        let [i, j] = [j+1, end]
      elseif j > i
        let j -= 1
      else
        Echow 'Invalid git commands!' | return
      endif
    endwhile
  endwhile
  for c in cmds
    execute g:git_cmds[c]
  endfor
endfunction

" Imitate s:GitComplete()
function! git#compcmd(A, L, P) abort
  return s:compcmd(a:A, a:L, a:P)
endfunction
let s:compcmd = function(s:fugisid.'_GitComplete')

" Imitate s:EditComplete()
function! git#compfile(A, L, P) abort
  return map(fugitive#repo().superglob(a:A), 'fnameescape(v:val)')
endfunction

if !exists('g:git_cmds') | let g:git_cmds = {} | endif
let g:git_cmds.w = 'noautocmd update'
let g:git_cmds.wa = 'noautocmd wall'
let g:git_cmds.s = 'Gstatus'

let g:git_cmds.a = 'update | execute "G add" resolve(expand("%:p"))[len(resolve(b:git_dir))-4:]'
let g:git_cmds.au = 'G add --update'
let g:git_cmds.A = 'G add --update'
let g:git_cmds.aa = 'G add --all'

let g:git_cmds.c = 'Gcommit -v'
let g:git_cmds.ca = 'Gcommit --all -v'
let g:git_cmds.C = 'Gcommit --all -v'
let g:git_cmds.cm = 'Gcommit --amend -v'
let g:git_cmds.cam = 'Gcommit --all --amend -v'
let g:git_cmds.cma = 'Gcommit --all --amend -v'
let g:git_cmds.cah = 'G commit --amend -C HEAD | GitGutterAll'
let g:git_cmds.ce = "G commit --allow-empty-message -m '' | GitGutterAll"
let g:git_cmds.cae = "G commit --all --allow-empty-message -m '' | GitGutterAll"
let g:git_cmds.cea = "G commit --all --allow-empty-message -m '' | GitGutterAll"

let g:git_cmds.d = 'tab sbuffer % | Gdiff'
let g:git_cmds.b = 'Gblame'
let g:git_cmds.l = 'Glog'
let g:git_cmds.ps = 'Gpush'
let g:git_cmds.pf = 'Gpush -f'
let g:git_cmds.pl = 'Gpull'

let g:git_cmds.u = 'GitGutter'
let g:git_cmds.U = 'GitGutterAll'
