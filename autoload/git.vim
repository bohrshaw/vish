" Depend on `git` related bundles like "vim-fugitive".

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
    if !batch && exists('s:cmds["'.s.'"]')
      break
    endif
  endwhile
  let end = len(s)-1
  let [i, j, cmds] = [0, end, []]
  while i <= j
    while j >= i
      let c = s[i : j]
      if exists('s:cmds["'.c.'"]')
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
    execute s:cmds[c]
  endfor
endfunction

let s:cmds = {
      \ 'w':   'update',
      \ 'wa':  'wall',
      \ 's':   'Gstatus',
      \
      \ 'a':      'update | call fugitive#repo().git_chomp_in_tree("add", expand("%:p")[len(b:git_dir)-4:])',
      \ 'au':     'G add --update',
      \ 'A':      'G add --update',
      \ 'aa':     'G add --all',
      \ "\<M-a>": 'G add --all',
      \
      \ 'c':   'Gcommit -v',
      \ 'cua': 'Gcommit --all --amend -v',
      \ 'cau': 'Gcommit --all --amend -v',
      \ 'cu':  'Gcommit --all -v',
      \ 'C':   'Gcommit --all -v',
      \ 'ca':  'Gcommit --amend -v',
      \ 'cah': 'G commit --amend -C HEAD | GitGutterAll',
      \ 'ce':  "G commit --allow-empty-message -m '' | GitGutterAll",
      \ 'cue': "G commit --all --allow-empty-message -m '' | GitGutterAll",
      \ 'ceu': "G commit --all --allow-empty-message -m '' | GitGutterAll",
      \ 'cs':  'B! git -C '.$MYVIM.'/spell commit --all -m "Spell"',
      \
      \ 'd':   'tab sbuffer % | Gdiff',
      \ 'b':   'Gblame',
      \ 'l':   'Glog',
      \ 'ps':  'G! push',
      \ 'pf':  'G! push -f',
      \ 'pl':  'G! pull',
      \ 'r':   'G! roll',
      \
      \ 'u':  'GitGutter',
      \ 'U':  'GitGutterAll',
      \ }
