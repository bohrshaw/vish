"  _  _ ____ _    _    ____      _  _ _ _  _ |
"  |__| |___ |    |    |  |      |  | | |\/| |
"  |  | |___ |___ |___ |__| .     \/  | |  | .
"                           '
" This is the Vim(Neovim) initialization file, plugin settings are splited into
" "vimrc.bundle". This file is categorized practically.
"
" Author: Bohr Shaw <pubohr@gmail.com>

" Comments:" {{{
" Be: healthy, stable, efficient, consistent, intuitive, convenient, accessible!

" First and foremost, master the help system. (:h helphelp)
" For an overview, :h quickref, :h index
" Could view and set all options. (:h :options)
" See minimal sensible settings: https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim
" Analyse startup performance with profile.sh

" Mapping notes:
" Use <C-c> instead of <Esc> to cancel a mapping
" :h map-which-keys
" Potentially unused keys: "\ <Space> <CR> <BS> Z Q R S X _ !"
" Keys waiting for a second key: "f t d c g z v y m q ' [ ]"
" Special keys like <CR>, <BS> are often mapped solely, as well as 'q' which is
" often mapped to quit a window.
" <Tab>/<C-I>, <CR>/<C-M>, <Esc>/<C-[> are pairs of exactly same keys.
" Some keys like Caps Lock, <C-1>, <C-S-1> etc. are not mappable.
" <C-J> is the same as <C-j>, use <C-S-j> instead.

" }}}
" Fundamental:" {{{
" Define an augroup for all autocmds in this file and empty it:" {{{
augroup vimrc
  autocmd!
augroup END
" }}}
" Vim Starting:" {{{
if has('vim_starting')
  set all& " override system vimrc
  set nocompatible " make Vim behave in a more useful way

  " Whether to include the least number of bundles, for shell command line editing
  let g:l = get(g:, 'l') || argv(0) =~# '^\V'.
        \(empty($TMPPREFIX)?'/tmp/zsh':$TMPPREFIX).'ecl\|'.$TMP.'/bash-fc'

  set rtp^=$HOME/.vim rtp+=$HOME/.vim/after " be portable
  if has('gui_running') || $termencoding ==? 'utf-8'
    set encoding=utf-8 " used inside Vim, allow mapping with the ALT key
  endif
endif " }}}
" set timeoutlen=3000 " mapping delay
set ttimeoutlen=10 " key code delay (instant escape from Insert mode)
" Meta-VimScript:" {{{
" let mapleader = "\r" " replace <Leader> in a map
let maplocalleader = "\t" " replace <LocalLeader> in a map
let g:mapinsertleader = "\<M-g>"
noremap <Tab> <Nop>
" Commands for defining mappings in several modes
command! -nargs=1 NXnoremap nnoremap <args><Bar> xnoremap <args>
command! -nargs=1 NXmap nmap <args><Bar>xmap <args>
command! -nargs=1 NXOnoremap nnoremap <args><Bar>xnoremap <args><Bar>onoremap <args>
command! -nargs=1 NXOmap nmap <args><Bar>xmap <args><Bar>omap <args>
" Allow chained commands, but also check for a " to start a comment
command! -bar -nargs=1 NXInoremap nnoremap <args><Bar> xnoremap <args><Bar>
      \ inoremap <args>
" }}}
" Deal with meta-key mappings:" {{{
if has('nvim')
  " Map meta-chords to esc-sequences in terminal
  for c in split("abcdefghijklmnopqrstuvwxyz,./;'[]\\-=`", '\zs')
    execute 'tnoremap '.'<M-'.c.'> <Esc>'.c
  endfor
  tnoremap <M-CR> <Esc><CR>
else
  runtime autoload/key.vim " mappable meta key in terminals
endif " }}}
if has('nvim') " skip python check to reduce startup time
  let [g:python_host_skip_check, g:python3_host_skip_check] = [1, 1]
endif
" }}}
" Shortcuts:" {{{
" Enter the command line:" {{{
NXnoremap <Space> :
inoremap <M-Space> <Esc>:
NXnoremap <M-Space> q:
" set cedit=<C-G>
cnoremap <M-Space> <C-F>
" q/ is not reliable as q is often solely mapped to quitting
NXnoremap <M-/> q/
if has('nvim')
  tnoremap <M-Space> <C-\><C-N>:
endif
" Mappings for the cmdline window
autocmd vimrc CmdwinEnter * noremap <buffer> <F5> <CR>q:|
      \ NXInoremap <buffer> <nowait> <CR> <CR>|
      \ NXInoremap <buffer> <M-q> <C-c><C-c>
" }}}
" Escape:" {{{
inoremap <M-i> <Esc>
if has('nvim')
  tnoremap <M-i> <C-\><C-N>
endif
inoremap <M-o> <C-O>
" }}}
" Yank till the line end instead of the whole line
nnoremap Y y$
" Character-wise visual mode
nnoremap vv ^vg_
nnoremap vV vg_
" quick access to GUI/system clipboard
NXnoremap "<Space> "+
" Access to the black hole register
NXnoremap _ "_
" Toggle fold methods
nnoremap <silent> zfm :let &l:foldmethod = tolower(matchstr(
      \':Manual:marker:indent:syntax:expr:diff',
      \'\C:\zs'.nr2char(getchar()).'\w*'))\|set foldmethod<CR>
" Run a command with a bang(!):" {{{
" For the current command
cnoremap <M-1> <C-\>e<SID>insert_bang()<CR><CR>
" For the last command
nnoremap @! :<Up><C-\>e<SID>insert_bang()<CR><CR>
function! s:insert_bang()
  let [cmd, args] = split(getcmdline(), '\v(^\a+)@<=\ze(\A|$)', 1)
  return cmd.'!'.args
endfunction
" }}}
" Execute a remapped key in its un-remapped(vanilla) state
NXOnoremap <expr>\\ nr2char(getchar())
" Todo: Execte a global key shadowed by the same local one
" noremap g\ ...
" }}}
" Motion:" {{{
" Navigate the jumper list more quickly
nnoremap <M-i> <C-I>
nnoremap <M-o> <C-O>
" Go to the last-accessed or second-newest position in the change list
nnoremap g. g,g;
" Print the change list or mark list
cabbrev chs changes
cabbrev ms marks
set matchpairs+=<:> " character pairs matched by '%'
if !has('nvim') " nvim put it in plugin/
  runtime macros/matchit.vim " extended pair matching with '%'
endif
" Jump to the middle of the current written line as opposed to the window width
nnoremap <silent> gm :call cursor(0, virtcol('$')/2)<CR>|nnoremap gM gm
" Auto-place the cursor when switching buffers or files:" {{{
" Don't move the cursor to the start of the line when switching buffers
augroup vimrc_cursor
  autocmd!
  autocmd BufLeave * set nostartofline|
        \autocmd vimrc_cursor CursorMoved * set startofline|
        \autocmd! vimrc_cursor CursorMoved
augroup END
" Jump to the last known position in a file just after opening it
autocmd vimrc BufRead * silent! normal! g`"
autocmd vimrc BufWinEnter * normal! zv
" }}}
" }}}
" Search:" {{{
set incsearch " show matches when typing the search pattern
set nohlsearch " highlight all matches of a search pattern
set ignorecase " case insensitive in search patterns and command completion
set smartcase " case sensitive only when up case characters present
" Mark position before search
NXnoremap / ms/
" Search the literal text of a visual selection:" {{{
xnoremap * :<C-u>call <SID>v_search('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>v_search('?')<CR>?<C-R>=@/<CR><CR>
function! s:v_search(dir)
  normal! gv"zy
  let @/ = '\V' . substitute(escape(@z, a:dir.'\'), '\n', '\\n', 'g')
endfunction" }}}
" Substitute in a visual area:" {{{
xnoremap cs :s/\%V
" Substitute in a visual area (eat the for-expanding-space)
" Hack: Use an expression to save a temporary value.
cabbrev <expr> sv 's/\%V'.
      \ setreg('z', nr2char(getchar(0)))[1:0].(@z == ' ' ? '' : @z)
" }}}
" Grep:" {{{
if executable('ag')
  set grepprg=ag\ --column " --nocolor --nobreak implicitly
  set grepformat^=%f:%l:%c:%m " the output format when not running interactively
elseif executable('ack')
  set grepprg=ack\ --column
  set grepformat^=%f:%l:%c:%m
endif
" A wrapper around grep using 'ag' or 'ack' without affecting 'grepprg' and
" 'grepformat'. Notice that a grep command like :grep, :lgrep, :grepadd etc.
" still needs to be explicitly specified.
command! -bar -nargs=+ -complete=file WithAg call grep#grep('ag', <q-args>)
command! -bar -nargs=+ -complete=file WithAck call grep#grep('ack', <q-args>)
" Grep all HELP docs preferably with ag, ack, helpgrep, in this order
command! -nargs=+ -complete=command Help call grep#help(<q-args>)
" A shortcut to ":Help grep"
command! -nargs=+ -complete=command Helpgrep call grep#help('grep '.<q-args>)
" Grep through all buffers
command! -nargs=1 BufGrep cexpr [] | bufdo vimgrepadd <args> %
" command! -nargs=1 BufGrep cexpr [] | mark Z |
"       \ execute "bufdo silent! g/<args>/caddexpr
"       \ expand('%').':'.line('.').':'.getline('.')" | normal `Z
" }}}
" QuickFix:" {{{
" Execute a command in each buffer in the quickfix or location list
command! -nargs=1 -complete=command Qdo call vimrc#errdo('q', <q-args>)
command! -nargs=1 -complete=command Ldo call vimrc#errdo(<q-args>)
" Clear the current quickfix list
command! -bar Cclear call setqflist([])
" Mappings/options for a quickfix/location window
autocmd vimrc FileType qf nnoremap <buffer> <nowait> <CR> <CR>|
      \ nnoremap <buffer> q <C-W>c|
      \ nnoremap <buffer> <M-v> <C-W><CR><C-W>H|
      \ nnoremap <buffer> <M-t> <C-W><CR><C-W>T
" }}}
" }}}
" View:" {{{
" Window management leader key
NXmap <M-w> <C-W>
nnoremap <M-j> <C-W>w
nnoremap <M-k> <C-W>W
nnoremap <M-q> <C-W>q
inoremap <M-q> <Esc><C-W>q
" Quick exit, useful when editing the shell command line
inoremap <M-z> <Esc>ZZ
" Tab is a collection of windows
NXnoremap <silent><M-l> :<C-u>execute repeat('tabn\|', v:count1-1).'tabn'<CR>
NXnoremap <M-h> gT
NXnoremap <silent><C-w>Q :tabclose<CR>
NXnoremap <silent><C-w><M-l> :<C-u>execute 'tabmove+'.v:count1<CR>
NXnoremap <silent><C-w><M-h> :<C-u>execute 'tabmove-'.v:count1<CR>
" Deal with terminal buffers
if has('nvim')
  tnoremap <M-w> <C-\><C-n><C-w>
  tnoremap <M-j> <C-\><C-n><C-w>w
  tnoremap <M-k> <C-\><C-n><C-w>W
  tnoremap <M-q> <C-\><C-n><C-W>q
  tmap <M-t> <C-\><C-n><M-t>
  tnoremap <M-T> <C-\><C-n>gT
  autocmd vimrc BufWinEnter,WinEnter term://* startinsert
  autocmd vimrc BufLeave term://* stopinsert
endif
" }}}
" Content:" {{{
" Edit the alternative file
nnoremap <M-a> <C-^>
if has('nvim')
  tnoremap <M-a> <C-\><C-n><C-^>
endif
" Split the window and edit the alternate file
NXnoremap <C-W><M-s> <C-w>^
NXnoremap <C-W><M-v> :vsplit #<CR>
" Split a buffer in a vertical window or a new tab
cabbrev vb vert sb
cabbrev tb tab sb
" Ways to delete buffers:" {{{
" Delete the current buffer without closing its window
command! -bang Bdelete :b# |silent! bd<bang>#
" Delete all buffers in the buffer list
command! BufDeleteAll execute '1,'.bufnr('$').'bdelete'
" Delete all buffers in the buffer list except the current one
command! BufOnly let nc = bufnr('%') |let nl = bufnr('$') |
      \ silent! execute nc > 1 ? '1,'.(nc-1).'bdelete |' : ''
      \ nl > nc ? (nc+1).','.nl.'bdelete' : ''
" Wipe out all unlisted buffers
command! BwipeoutUnlisted call vimrc#bufffer_wipe_unlisted()
" }}}
set autoread " auto-read a file changed outside of Vim
" set autowrite " auto-write a modified file when switching buffers
set hidden " hide a modified buffer without using '!' when it's abandoned

" Edit a file in the same directory of the current file
NXnoremap <leader>ee :e <C-R>=expand('%:h')<CR>/<Tab>
NXnoremap <leader>es :sp <C-R>=expand('%:h')<CR>/<Tab>
NXnoremap <leader>ev :vs <C-R>=expand('%:h')<CR>/<Tab>
NXnoremap <leader>et :tabe <C-R>=expand('%:h')<CR>/<Tab>
" Edit a file in a new tab
cabbrev te tabe
set path=.,,~ " directories to search by 'gf', ':find', etc.
set cdpath=.,,~/workspaces " directories to search by ':cd', ':lcd'
" Open a destination file of a link:" {{{
cnoremap <M-l> <C-\>e<SID>get_link_targets()<CR><CR>
function! s:get_link_targets()
  let [cmd; links] = split(getcmdline())
  for l in links
    let cmd .= ' '.fnamemodify(resolve(expand(l)), ':~:.')
  endfor
  return cmd
endfunction
" }}}
" Easy access to vimrc files:" {{{
cabbrev .v ~/.vim/vimrc
cabbrev .b ~/.vim/vimrc.bundle
" Pseudo global marks for jumping to the last position in a file
NXnoremap <silent> 'V :let _f = expand('~/.vim/vimrc')\|
      \ execute (buflisted(_f)?'b ':'e ') . _f<CR>
NXnoremap <silent> 'B :let _f = expand('~/.vim/vimrc.bundle')\|
      \ execute (buflisted(_f)?'b ':'e ') . _f<CR>
" }}}
" Make the file '_' a scratch buffer
autocmd vimrc BufNewFile,BufReadPost _ set buftype=nofile nobuflisted bufhidden=hide
autocmd vimrc SessionLoadPost * silent! bwipeout! _
if has('vim_starting') && 0 == argc() && has('gui_running') && !g:l
  cd $HOME
endif
" Recognise a file's encoding in this order
" set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,latin1
set fileformats=unix,dos,mac " end-of-line formats precedence
set fileformat=unix " only for the initial unnamed buffer
set nowritebackup " write to symbolic files safely on windows
" }}}
" Completion:" {{{
" A smart and light <Tab> to do insert-completion:" {{{
inoremap <expr> <Tab> getline('.')[col('.')-2] !~ '^\s\?$' \|\| pumvisible()
      \ ? '<C-N>' : '<Tab>'
inoremap <expr> <S-Tab> pumvisible() \|\| getline('.')[col('.')-2] !~ '^\s\?$'
      \ ? '<C-P>' : '<Tab>'
" Remove auto-definded mappings
autocmd vimrc CmdwinEnter * silent! iunmap <buffer> <Tab>
" }}}
" CTRL-X completion-sub-mode :" {{{
" Shortcuts
imap <M-x> <C-X>
for s:c in split('lnpkti]fdvuos', '\zs')
  execute 'inoremap <C-X>'.s:c.' <C-X><C-'.s:c.'>'
endfor
" Insert previously inserted text
inoremap <C-X>. <C-A>
" Dictionary files for insert-completion
let s:dictionaries = '~/.vim/spell/dictionary-oald.txt'
if filereadable(expand(s:dictionaries))
  let &dictionary = s:dictionaries
elseif !has('win32')
  set dictionary=/usr/share/dict/words
else
  set dictionary=spell " completion from spelling as an alternative
endif
" Thesaurus files for insert-completion
set thesaurus=~/.vim/spell/thesaurus-mwcd.txt
" Enable spell checking for particular file types
autocmd vimrc FileType gitcommit,markdown,txt setlocal spell
if v:version == 704 && has('patch088') || v:version > 704
  set spelllang+=cjk " skip spell check for East Asian characters
endif
" }}}
" Auto-reverse letter case in insert mode {{{
inoremap <M-l> <C-R>=<SID>toggle(1)<CR>
inoremap <M-L> <C-R>=<SID>toggle(2)<CR>
function! s:toggle(arg)
  let b:case_reverse = get(b:, 'case_reverse') ? 0 : a:arg
  if !exists('#case_reverse#InsertCharPre#<buffer>')
    augroup case_reverse
      autocmd InsertCharPre <buffer> if b:case_reverse|
            \ let v:char = v:char =~# '\l' ? toupper(v:char) : tolower(v:char)|
            \ endif|
            \ if b:case_reverse == 1 && v:char !~ '\h'|
            \ let b:case_reverse = 0|
            \ endif
      " Wouldn't be triggered if leaving insert mode with <C-C>
      autocmd InsertLeave <buffer> let b:case_reverse = 0| autocmd! case_reverse
    augroup END
  endif
  return ''
endfunction
" }}}
set completeopt=menu,longest " insert-completion mode
set complete-=i " don't scan included files when insert-completing by <C-N/P>
set pumheight=15 " max candidates on insert-mode completion

set wildcharm=<Tab> " the key to trigger wildmode expansion in mappings
set wildmenu wildmode=longest:full,full " command line completion mode
silent! set wildignorecase " ignore case when completing file names/directories
" Show all candidates
cnoremap <M-a> <C-d>
" Make a command(e.g. `:h ...`) split vertically or in a new tab.
cnoremap <M-w>v <C-\>e'vert '.getcmdline()<CR><CR>
cnoremap <M-w>t <C-\>e'tab '.getcmdline()<CR><CR>
" Expand a mixed case command name:" {{{
cnoremap <M-j> <C-\>e<SID>cmd_expand()<CR><Tab>
function! s:cmd_expand()
  let cmd = getcmdline()
  let [range, abbr] = [matchstr(cmd, '^\A*'), matchstr(cmd, '\a.*')]
  let parts = map(split(abbr, abbr =~ '\s' ? '\s' : '\zs'), 'toupper(v:val[0]).v:val[1:]')
  return range . join(parts, '*')
endfunction " }}}

" Abbreviations" {{{
" Trigger abbreviation
noremap! <M-]> <C-]>

abbr bs Bohr Shaw
" }}}

" Type notated keys {{{
noremap! <expr><M-v> <SID>special_key()
function! s:special_key()
  let c1 = v#getchar()
  if empty(c1)
    return ''
  endif
  if has_key(s:keymap, c1) == 1
    return s:keymap[c1]
  endif
  let c2 = v#getchar()
  if empty(c2)
    return ''
  endif
  let c2_ = has_key(s:keymap_sp, c2) ? s:keymap_sp[c2] : c2
  let cc = c1.c2
  if has_key(s:keymap, cc) == 1
    return s:keymap[cc]
  elseif cc =~# 'c.'
    return '<C-'.(c2 =~# '\u' ? 'S-'.tolower(c2_) : c2_).'>'
  elseif cc =~# 'C.'
    return 'ctrl-'.c2
  elseif cc =~# '[md].'
    return '<'.toupper(c1).'-'.c2_.'>'
  else
    return ''
  endif
endfunction
let s:keymap_sp = {
      \"\<Tab>": 'Tab',
      \' ':      'Space',
      \"\<CR>":  'CR',
      \"\<BS>":  'BS',
      \}
let s:keymap = {
      \"\<Tab>": '<Tab>',
      \'E':      '<Esc>',
      \' ':      '<Space>',
      \"\<CR>":  '<CR>',
      \"\<BS>":  '<BS>',
      \'<':      '<LT>',
      \'\':      '<Bslash>',
      \'|':      '<Bar>',
      \'bu':     '<buffer>',
      \'no':     '<nowait>',
      \'si':     '<silent>',
      \'sp':     '<special>',
      \'sc':     '<script>',
      \'ex':     '<expr>',
      \'un':     '<unique>',
      \'L':      '<Leader>',
      \'ll':     '<LocalLeader>',
      \'lL':     '<LocalLeader>',
      \'P':      '<Plug>',
      \'S':      '<SID>',
      \'N':      '<Nop>',
      \'l1':     '<line1>',
      \'l2':     '<line2>',
      \'co':     '<count>',
      \'re':     '<reg>',
      \'ba':     '<bang>',
      \'ar':     '<args>',
      \'qa':     '<q-args>',
      \'fa':     '<f-args>',
      \}
" }}}
" }}}
" Repeat:" {{{
" Clear undo history (:w to clear the undo file if presented)
command! -bar UndoClear execute 'set undolevels=-1 |move -1 |'.
      \ 'let [&modified, &undolevels] = ['.&modified.', '.&undolevels.']'

" Repeat last change on each line in a visual selection
xnoremap . :normal! .<CR>
" Execute a macro on each one in {count} lines
nnoremap <silent> @. :call <SID>macro()<CR>
function! s:macro() range
  execute a:firstline.','.a:lastline.'normal! @'.nr2char(getchar())
endfunction
" Execute a macro on each line in a visual selection
xnoremap <silent> @ :<C-u>execute ":'<,'>normal! @".nr2char(getchar())<CR>
" Execute a macro without remapping
NXnoremap <expr> <silent> @2 repeat(
      \ ':<C-U>normal! <C-R><C-R>'.nr2char(getchar()).'<CR>', v:count1)
" Finish and execute a recursive macro
nnoremap <silent>Q q:let _r = v#getchar()\|
      \call setreg(_r, getreg(_r).'@'._r)\|
      \execute 'normal! @'._r<CR>
" Keep the flags when repeating last substitution
NXnoremap & :&&<CR>
" Refine the last command
NXnoremap @<Space> @:
NXnoremap @; :verbose @:<CR>
NXnoremap @: :Verbose @:<CR>
" }}}
" Diff:" {{{
xnoremap <silent> do :execute &diff ? "'<,'>diffget" : ''<CR>
xnoremap <silent> dp :execute &diff ? "'<,'>diffput" : ''<CR>
nnoremap <silent> du :execute &diff ? 'diffupdate' : ''<CR>
" Switch off diff mode and close other diff panes
nnoremap dO :diffoff \| windo if &diff \| hide \| endif<CR>
" Diff with another file
command! -nargs=? -complete=buffer DiffWith call vimrc#diffwith(<f-args>)
" }}}
" Persistence:" {{{
let &swapfile = g:l ? 0 : 1 " use a swapfile for the buffer
set undofile " remember undo history across sessions
" Remember uppercase global variables, number of files in which marks are
" remembered(:oldfiles), ... , and viminfo file name.
let &viminfo = "!,'444,<50,s10,h,n$HOME/.vim/tmp/viminfo"
let _viminfo = &viminfo " for quick interactive restoring
" Exclude options and mappings and be portable
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize,slash,unix
set viewoptions=folds,cursor,slash,unix
" Set default paths of temporary files
let opts = {'directory': 'swap', 'undodir': 'undo', 'backupdir': 'backup'}
for [opt, dir] in items(opts)
  let value = $HOME . '/.vim/tmp/' . dir
  if !isdirectory(value) | silent! call mkdir(value) | endif
  execute "set " . opt . "^=" . value
endfor
set viewdir=~/.vim/tmp/view
" }}}
" Readline:" {{{
" Recall older or more recent command-line from history, but the command matches
" the current command-line
cnoremap <M-p> <Up>
cnoremap <M-n> <Down>
" Move the cursor around the line
inoremap <C-A> <C-O>^
cnoremap <C-A> <Home>
inoremap <C-E> <End>
" Move the cursor around one word
noremap! <M-f> <S-Right>
noremap! <M-b> <S-Left>
" Move the cursor around one character
noremap! <C-F> <Right>
noremap! <C-B> <Left>
" Delete one word before the cursor
noremap! <M-BS> <C-w>
" Delete one word after the cursor
inoremap <M-d> <C-O>dw
cnoremap <M-d> <S-Right><C-W>
" Delete one character after the cursor
inoremap <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
" Transpose two characters around the cursor
cmap <script><C-T> <SID>transposition<SID>transpose
noremap! <expr> <SID>transposition getcmdpos() > strlen(getcmdline()) ?
      \ "\<Left>" : getcmdpos()>1 ? '' : "\<Right>"
noremap! <expr> <SID>transpose "\<BS>\<Right>"
      \ . matchstr(getcmdline()[0 : getcmdpos()-2], '.$')
" }}}
" Bundles:" {{{
if has('vim_starting')
  runtime vimrc.bundle " bundle configuration
  BundleInject " inject bundle paths to 'rtp'

  " Must be after setting 'rtp'
  filetype plugin indent on
  syntax enable
endif
" }}}
" Appearance:" {{{
" List special or abnormal characters:" {{{
set list " show non-normal spaces, tabs etc.
if &encoding ==# 'utf-8' || &termencoding ==# 'utf-8'
  " No reliable way to detect putty
  let s:is_win_ssh = has('win32') || !empty('$SSH_TTY')
  " Special unicode characters/symbols:
  " ¬ ¶ ⏎ ↲ ↪ ␣ ¨ ⣿ │ ░ ▒ ⇥ → ← ⇉ ⇇ ❯ ❮ » « ↓ ↑
  " ◉ ○ ● • · ■ □ ¤ ▫ ♦ ◆ ◇ ▶ ► ▲ ▸ ✚ ★ ✸ ✿ ✜ ☯ ☢ ❀ ♥ ♣ ♠
  let s:lcs = split(s:is_win_ssh ? '· · » « ▫' : '· ␣ ❯ ❮ ▫')
  let &showbreak = s:is_win_ssh ? '→' : '❯'
  set fillchars=vert:│,fold:-,diff:-
else
  let s:lcs = ['>', '-', '>', '<', '+']
endif
execute 'set listchars=tab:'.s:lcs[0].'\ ,trail:'.s:lcs[1]
      \ .',extends:'.s:lcs[2].',precedes:'.s:lcs[3].',nbsp:'.s:lcs[4]
" Avoid showing trailing whitespace when in insert mode
execute 'autocmd vimrc InsertEnter * set listchars-=trail:'.s:lcs[1]
execute 'autocmd vimrc InsertLeave * set listchars+=trail:'.s:lcs[1]
" }}}
" Status line(I name it as "Starline"):" {{{
set laststatus=2 " always display the status line
" Ensure all plugins are loaded before setting 'statusline'
function! Vstatusline()
  set statusline=%m%.30f " modified flag, file name(truncated if length > 30)
  set statusline+=:%R%Y%W%q " read-only, filetype, preview, quickfix
  set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?':'.&fenc:''} " file encoding
  set statusline+=%{&ff!='unix'?':'.&ff:''} " file format
  " Git branch name
  let &statusline .= exists('*fugitive#head') ?
        \ "%{exists('b:git_dir')?':'.fugitive#head(7):''}" : ''
  " set statusline+=%{':'.matchstr(getcwd(),'.*[\\/]\\zs\\S*')}
  set statusline+=%{get(b:,'case_reverse',0)?':CASE':''} " software caps lock
  set statusline+=%= " left/right separator
  set statusline+=%c:%l/%L:%P " cursor position, line percentage
endfunction
execute (has('vim_starting')?'autocmd vimrc VimEnter * ':'').'call Vstatusline()'
set fillchars+=stl::,stlnc:~ " characters to fill the statuslines
" Ensure the same statusline/tabline highlighting in any color scheme
autocmd vimrc ColorScheme * hi StatusLine
      \ term=bold cterm=bold ctermfg=40 ctermbg=233
      \ gui=bold guifg=#00d700 guibg=#171717 |
      \ hi StatusLineNC
      \ term=NONE cterm=NONE ctermfg=131 ctermbg=233
      \ gui=NONE guifg=#be7572 guibg=#171717 |
      \ hi! link TabLineSel StatusLine |
      \ hi! link TabLine StatusLineNC |
      \ hi! link TabLineFill StatusLineNC |
if !has('vim_starting')
  doautocmd vimrc ColorScheme *
endif
" The status line for the quickfix window
autocmd vimrc FileType qf setlocal statusline=%t
      \%{strpart('\ '.get(w:,'quickfix_title',''),0,66)}%=\ %11.(%c,%l/%L,%P%)
" Use CTRL-G, G_CTRL-G to see file and cursor information manually
set ruler " not effective when 'statusline' is set
set rulerformat=%50(%=%m%r%<%f%Y\ %c,%l/%L,%P%)
" }}}
let &showtabline = g:l ? 1 : 2
" set tabline=
set titlestring=%{getcwd()}
" set number " print the line number in front of each line
set relativenumber " show the line number relative to the current line
set numberwidth=3 " minimal number(2) of columns to use for the line number
" Font, color, window size:" {{{
if has('vim_starting')
  if has('gui_running')
    if has('win32')
      set guifont=Consolas:h10
      autocmd vimrc GUIEnter * simalt ~x " maximize window
    else
      set guifont=Consolas\ 10
      set lines=250 columns=200
    endif
  else
    " Assume 256 colors
    if &term =~ '\v(xterm|screen)$' | let &term .= '-256color' | endif
    " Disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    " See also http://snk.tuxfamily.org/log/vim-256color-bce.html
    if &term =~ '256col' | set t_ut= | endif
    " Allow color schemes do bright colors without forcing bold.
    if &t_Co == 8 && &term !~ '^linux' | set t_Co=16 | endif
  endif
  set background=dark " assume a dark background for color schemes
endif
" }}}
set showcmd "show partial commands in status line
" set showmatch matchtime=1 " better using highlighting in plugin/matchparen.vim
silent! set breakindent " indent wrapped lines
set linebreak " don't break a word when displaying wrapped lines
set colorcolumn=+1 " highlight column after 'textwidth'
set display+=lastline " ensure the last line is properly displayed
" if has('multi_byte_ime')
"   highlight CursorIM guifg=NONE guibg=#007500
" endif
" }}}
" Misc:" {{{
if has('vim_starting')
  set autoindent " indent at the same level of the previous line
  set shiftwidth=4 " number of spaces to use for each step of (auto)indent
  set shiftround " round indent to multiple of 'shiftwidth'
  set tabstop=4 " number of spaces a tab displayed in
  set softtabstop=4 " number of spaces used when press <Tab> or <BS>
  set expandtab " expand a tab to spaces
  set smarttab " <Tab> in front of a line inserts blanks according to 'shiftwidth'
endif
set mouse=a " enable mouse in all modes
" Sync visual mode selection with the selection register(*) in supported GUI
execute has('gui_gtk')||has('gui_motif')||has('gui_athena') ? 'set go+=a' : ''
" set clipboard+=unnamed " sync the selection register with the unnamed register
set scrolloff=1 " minimum lines to keep above and below cursor
set sidescrolloff=5 " minimal number of screen columns to keep around the cursor
set backspace=indent,eol,start " backspace through anything in insert mode
silent! set formatoptions+=j " remove a comment leader when joining lines
set nrformats-=octal " 01 is treated as decimal
set lazyredraw " don't redraw the screen while executing macros, etc.
set shortmess=aoOtTI " avoid all the hit-enter prompts caused by file messages
" autocmd vimrc GUIEnter * set vb t_vb= " disable error beep and screen flash
set guioptions=M " skip sourcing menu.vim, before enabling filetype/syntax
set guioptions+=c " use a console dialog for confirmation instead of a pop-up
set confirm " prompt for an action instead of fail immediately
set winminheight=0 " the minimal height of a window
set history=1000 " maximum number of commands and search patterns to keep
set synmaxcol=999 " ignore further syntax items to avoid slow redrawing
silent! set cryptmethod=blowfish cm=blowfish2 " acceptable encryption
silent! set langnoremap " 'langmap' doesn't apply to characters resulting from a mapping
" Make 'cw' consistent with 'dw'
" onoremap <silent> w :execute 'normal! '.v:count1.'w'<CR>

" Join lines without any character or with specified characters in between
command! -range -nargs=? Join <line1>,<line2>-1s/\s*\n\s*/<args>/
" Remove trailing white spaces
command! -range=% Trim let _p=getpos('.')|
      \keepj keepp <line1>,<line2>s/\s\+$//| call setpos('.',_p)
" Execute an external command silently
command! -nargs=1 -complete=shellcmd Silent call system(<q-args>)
" Remove duplicate lines:" {{{
" Remove duplicate, consecutive lines (:sort /.\_^/ u)
command! -range=% Uniqc <line1>,<line2>g/\v^(.*)\n\1$/d
" Remove duplicate, nonconsecutive and nonempty lines (g/\v^(.+)$\_.{-}^\1$/d)
command! -range=% Uniqn <line1>,<line2>g/^./
      \ if search('^\V'.escape(getline('.'),'\').'\$', 'bW') |
      \ delete | endif <NL> silent! normal! ``
" }}}
" Toggle full screen
NXnoremap <F11> :<C-U>call libcallnr('gvimfullscreen.dll', "ToggleFullScreen", 0)<CR>
" Search via Google
command! -nargs=1 Google call netrw#NetrwBrowseX(
      \ "https://www.google.com/search?q=".expand("<args>"),0)
xnoremap <Leader>gg "zy:<C-u>Google <C-r>z<CR>
" Mystify texts
command! Mystify call misc#mystify()
" Reverse the selected text
xnoremap cR c<C-O>:set revins<CR><C-R>"<Esc>:set norevins<CR>
" Statistics:" {{{
" Count anything in a range of lines
command! -range=% -nargs=? Count echo vimrc#count
      \(<q-args>, <line1>, <line2>) | normal ``
" Calculate words frequency
command! -range=% WordFrequency echo vimrc#word_frequency(<line1>, <line2>)
" Calculate the total lines of source code minus blank lines and comment lines.
command! -range=% SLOC echo vimrc#count
      \('^[^' . &cms[0] . ']', <line1>, <line2>) | normal ``
" }}}

silent! source ~/.vimrc.local " machine specific config
" }}}

" vim:ft=vim tw=80 et sw=2 fdm=marker cms="\ %s:
