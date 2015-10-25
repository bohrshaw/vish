"  _  _ ____ _    _    ____      _  _ _ _  _ |
"  |__| |___ |    |    |  |      |  | | |\/| |
"  |  | |___ |___ |___ |__| .     \/  | |  | .
"                           '
" This is the Vim(Neovim) initialization file categorized practically.
" Bundle(plugin) dependent configs are splited into "vimrc.bundle".
"
" Author: Bohr Shaw <pubohr@gmail.com>

" Comments:" {{{
" Be: healthy, stable, efficient, consistent, intuitive, convenient, accessible!

" First and foremost, master the help system. (:h helphelp)
" For an overview, :h quickref, :h index
" Could view and set all options. (:h :options)
" See minimal sensible settings: https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim
" Analyse startup performance with vim-profile.sh

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
" Starting:" {{{
" Define an augroup for all autocmds in this file and empty it
augroup vimrc | execute 'autocmd!' | augroup END
if has('vim_starting')
  set all& " override system vimrc and cmdline options like --noplugin
  set nocompatible " make Vim behave in a more useful way

  if has('win32')
    " Wish to use a forward slash for path separator? But 'shellslash' is not
    " designed to be set alone. Plugins must explicitly cope with it. Wish a
    " 'internal_shellslash' be available!
    "
    " Plugins like 'fugitive' works regardless of this option. While more
    " plugins like 'gnupg', 'jedi' wouldn't function well when it's set.
    " Troublesomely, 'unite', 'vimproc' have problems when it's not set.
    set shellslash&
  endif

  let $MYVIMRC = empty($MYVIMRC) ? expand('<sfile>:p') :
        \ has('win32') ?
        \   filereadable($HOME.'/.vim/vimrc') ?
        \     expand('~/.vim/vimrc') : expand('~/vimfiles/vimrc') :
        \   resolve($MYVIMRC)
  let $MYVIM = fnamemodify($MYVIMRC, ':p:h') " be portable
  let g:ported = $MYVIM == expand('~/.vim') || $MYVIM == expand('~/vimfiles') ? 0 : 1

  " Cross-platform 'runtimepath'
  set rtp=$MYVIM,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$MYVIM/after

  if has('gui_running') || $termencoding ==? 'utf-8'
    set encoding=utf-8 " used inside Vim, allow mapping with the ALT key
  endif

  set timeout ttimeout " Nvim has different defaults
  " set timeoutlen=3000 " mapping delay
  if !has('nvim')
    set ttimeoutlen=10 " key code delay (instant escape from Insert mode)
  endif
  " Deal with meta-key mappings:" {{{
  if has('nvim')
    " Map meta-chords to esc-sequences in terminals
    for c in map(range(33, 123) + range(125, 126), 'nr2char(v:val)')
      execute 'tnoremap '.'<M-'.c.'> <Esc>'.c
      execute 'tnoremap '.'<M-C-'.c.'> <Esc><C-'.c.'>'
    endfor
    tnoremap <M-\|> <Esc>\|
    tnoremap <M-CR> <Esc><CR>
  else
    runtime autoload/key.vim " mappable meta key in terminals
  endif " }}}

  if has('nvim') " skip python check to reduce startup time
    let [g:python_host_skip_check, g:python3_host_skip_check] = [1, 1]
  endif

  " Whether to include the least number of bundles, for shell command line editing
  let g:l = get(g:, 'l', $VL) || argv(0) =~# '^\V'.
        \(empty($TMPPREFIX)?'/tmp/zsh':$TMPPREFIX).'ecl\|'.$TMP.'/bash-fc'

  let $MYVIMRCPRE = (g:ported ? $MYVIM.'/' : $HOME.'/.').'vimrc.pre.local'
  if filereadable($MYVIMRCPRE)
    execute 'silent source' $MYVIMRCPRE
  endif
endif " }}}
" Meta:" {{{
" Commands for defining mappings in several modes
command! -nargs=1 NXnoremap nnoremap <args><Bar> xnoremap <args>
command! -nargs=1 NXmap nmap <args><Bar>xmap <args>
command! -nargs=1 NOnoremap nnoremap <args><Bar> onoremap <args>
command! -nargs=1 NOmap nmap <args><Bar>omap <args>
command! -nargs=1 NXOnoremap nnoremap <args><Bar>xnoremap <args><Bar>onoremap <args>
command! -nargs=1 NXOmap nmap <args><Bar>xmap <args><Bar>omap <args>
" Allow chained commands, but also check for a " to start a comment
command! -bar -nargs=1 NXInoremap nnoremap <args><Bar> xnoremap <args><Bar>
      \ inoremap <args>

" let mapleader = "\r" " replace <Leader> in a map
let maplocalleader = "\t" " replace <LocalLeader> in a map
NXnoremap <Tab> <Nop>
let g:mapinsertleader = "\<M-g>"

" Execute a remapped key in its un-remapped(vanilla) state.
" Note: Use i_CTRL-D to insert a non-digit literally.
noremap <expr><M-\> nr2char(getchar())
noremap! <expr><M-\> nr2char(getchar())

" Execte a global mapping shadowed by the same local one
nnoremap <silent>g\ :call <SID>gmap('n')<CR>
xnoremap <silent>g\ :<C-u>call <SID>gmap('x')<CR>
function! s:gmap(mode) " {{{
  let lhs = ''
  while 1
    let c = v#getchar()
    if empty(c)
      return
    endif
    let lhs .= c
    let map = maparg(lhs, a:mode, 0, 1)
    if empty(map)
      continue
    endif
    try " the matched mapping may not be local
      execute a:mode.'unmap <buffer>' lhs
    catch
      Echow 'No such local mapping.' | return 1
    endtry
    execute 'normal' (a:mode == 'x' ? 'gv' : '').lhs
    execute a:mode.(map.noremap ? 'noremap' : 'map')
          \ map.silent ? '<silent>' : ''
          \ map.expr ? '<expr>' : ''
          \ map.nowait ? '<nowait>' : ''
          \ '<buffer>' map.lhs map.rhs
    return
  endwhile
endfunction " }}}

" Define a full-id abbreviation with minimal conflict
command! -nargs=1 Abbr execute substitute(<q-args>, '\v\s+\S+\zs', 'SoXx', '')
" Complete and trigger a full-id abbreviation
noremap! <M-]> SoXx<C-]>

" Echo a warning message. Note: A double-quote in <args> starts a comment.
command! -bar -nargs=1 Echow echohl WarningMsg | echo <args> | echohl None
" A command doing nothing while accepting args (for quick composition)
command! -nargs=* Nop :
" }}}
" Shortcuts:" {{{
" Escape
inoremap <M-i> <Esc>
if has('nvim')
  tnoremap <M-i> <C-\><C-N>
endif
inoremap <M-o> <C-O>

" The command line and the command line window
" {{{
NXnoremap <Space> :
if has('nvim')
  tnoremap <M-Space> <C-\><C-N>:
endif
" Resolve local mapping conflicts with <Space>
autocmd vimrc BufWinEnter option-window autocmd CursorMoved option-window
      \ execute 'nnoremap <silent><buffer><LocalLeader>r '.maparg("<Space>")|
      \ unmap <buffer><Space>|
      \ autocmd! CursorMoved option-window

NXnoremap <M-Space> q:
NXnoremap <M-e> q:
NXnoremap <M-/> q/
" set cedit=<C-G>
cnoremap <M-Space> <C-F>
cnoremap <M-e> <C-F>
cnoremap <M-;> <C-F>
inoremap <M-;> <Esc>:<C-F>
autocmd vimrc CmdwinEnter * noremap <buffer> <F5> <CR>q:|
      \ NXInoremap <buffer> <nowait> <CR> <CR>|
      \ NXInoremap <buffer> <M-q> <C-c><C-c>
"}}}

" Yank till the line end instead of the whole line
nnoremap Y y$

" Character-wise visual mode
nnoremap vv ^vg_
nnoremap vV vg_

" quick access to GUI/system clipboard
NXnoremap "<Space> "+

" Copy from the command line
cabbrev <expr>c getcmdtype() == ':' && getcmdpos() == 2 ? 'copy' : 'c'

" Access to the black hole register
NXnoremap _ "_

" Run the current command with a bang(!)
cnoremap <M-1> <C-\>e<SID>insert_bang()<CR><CR>
" Run the last command with a bang
nnoremap @! :<Up><C-\>e<SID>insert_bang()<CR><CR>
function! s:insert_bang() " {{{
  let [cmd, args] = split(getcmdline(), '\v(^\a+)@<=\ze(\A|$)', 1)
  return cmd.'!'.args
endfunction " }}}
" }}}
" Motion:" {{{
set virtualedit=onemore " consistent cursor position on EOL
set whichwrap& " left/right motions across lines

" Search forward/backward regardless of the direction of the previous character search"{{{
" Note: These are overwritten in Sneak, but the semantics retains.
if 0 && exists('*getcharsearch') " Vim patch 7.4.813
  NXOnoremap <expr>; getcharsearch().forward ? ';' : ','
  NXOnoremap <expr>, getcharsearch().forward ? ',' : ';'
elseif 0
  NOnoremap <silent>F :<C-u>execute 'silent! normal! mzf'.nr2char(getchar()).'g`z'.v:count1.','<CR>
  xnoremap <silent>F :<C-u>execute 'silent! normal! mzf'.nr2char(getchar()).'g`zgv'.v:count1.','<CR>
  NOnoremap <silent>T :<C-u>execute 'silent! normal! mzt'.nr2char(getchar()).'g`z'.v:count1.','<CR>
  xnoremap <silent>T :<C-u>execute 'silent! normal! mzt'.nr2char(getchar()).'g`zgv'.v:count1.','<CR>
endif "}}}

" Display lines up/down (consecutive motions are quicker)
nnoremap <C-j> gj
nnoremap <C-k> gk

" Jump to the middle of the current written line as opposed to the window width
nnoremap <silent> gm :call cursor(0, virtcol('$')/2)<CR>|nnoremap gM gm

" `%` jump between characters in 'matchpairs'
" set matchpairs+=<:> " < and > could appear in <=, ->, etc.
" Extended pair matching with the bundled plugin "matchit"
let g:loaded_matchit = 1 " disabled as `dV%` is unsupported, see matchit-v_%
if has('vim_starting') && !g:loaded_matchit
  if !has('nvim') " nvim put it in plugin/
    runtime macros/matchit.vim
  endif
  autocmd vimrc VimEnter * sunmap %|sunmap [%|sunmap ]%|sunmap a%|sunmap g%
endif

" Sections backword/forward
nmap <M-[> [[
nmap <M-]> ]]

" Navigate the change list
nnoremap <M-;> g;
nnoremap <M-,> g,
" Go to the second-newest or current position in the change list
nnoremap <silent>g. :try\|execute 'normal! g,g;'\|
      \ catch\|execute 'normal! g,'\|endtry<CR>

" Print the change list or mark list
cabbrev <expr>cs getcmdtype() == ':' && getcmdpos() == 3 ? 'changes' : 'cs'
cabbrev <expr>ms getcmdtype() == ':' && getcmdpos() == 3 ? 'marks' : 'ms'

" Navigate the jumper list
nnoremap <M-i> <C-I>
nnoremap <M-o> <C-O>

" Jump to the definition of the current tag
NXmap <CR> <C-]>

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
" }}}
" }}}
" Search:" {{{
set incsearch " show matches when typing the search pattern
if !&hlsearch|set hlsearch|endif " highlight all matches of a search pattern
set ignorecase " case insensitive in search patterns and command completion
set smartcase " case sensitive only when up case characters present
" Substitute in a visual area:" {{{
xnoremap sv :s/\%V
" Substitute in a visual area (eat the for-expanding-space)
" Hack: Use an expression to save a temporary value.
cabbrev <expr>sv getcmdtype() == ':' && getcmdpos() =~ '[38]' ?
      \ 's/\%V'.setreg('z', nr2char(getchar(0)))[1:0].(@z == ' ' ? '' : @z) : 'sv'
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
" Clear the current quickfix list
command! -bar Cclear call setqflist([])
" Mappings/options for a quickfix/location window
autocmd vimrc FileType qf nnoremap <buffer> <nowait> <CR> <CR>|
      \ nnoremap <buffer> q <C-W>c|
      \ nnoremap <buffer> <M-w>v <C-W><CR><C-W>H|
      \ nnoremap <buffer> <M-w>t <C-W><CR><C-W>T
if !has('patch-7.4.858') "{{{
  " Execute a command in each buffer in the quickfix or location list
  command! -nargs=1 -complete=command Cfdo call vimrc#errfdo(<q-args>)
  command! -nargs=1 -complete=command Lfdo call vimrc#errfdo(<q-args>, 1)
endif "}}}
" }}}
" }}}
" View:" {{{

" Scroll relative to cursor (@_ suppresses [count] for zt)
nnoremap <expr>zt v:count > 0 ? '@_zt'.v:count.'<c-y>' : 'zt'
nnoremap <expr>zb v:count > 0 ? '@_zb'.v:count.'<c-e>' : 'zb'

" The leader key for managing windows and tabs
NXmap <M-w> <C-W>

" Jump to {count}th next/previous window, able to jump back with <C-w>p
nnoremap <silent><C-w>j :<C-u>let _w = winnr() + v:count1 \|
      \ execute (_w > winnr('$') ? _w - winnr('$') : _w).'wincmd w'<CR>
nnoremap <silent><C-w>k :<C-u>let _w = winnr() - v:count1 \|
      \ execute (_w < 1 ? _w + winnr('$') : _w).'wincmd w'<CR>
for i in [2, 3, 4, 5]
  execute 'nmap <C-w>'.i.'j' i.'<C-w>j'
  execute 'nmap <C-w>'.i.'k' i.'<C-w>k'
endfor
nmap <M-j> <C-w>j
nmap <M-k> <C-w>k
nnoremap <M-q> <C-W>q
inoremap <M-q> <Esc><C-W>q

nnoremap <silent><M-l> :<C-u>execute repeat('tabn\|', v:count1-1).'tabn'<CR>
nnoremap <M-h> gT
nnoremap <silent><C-w><M-l> :<C-u>execute 'tabmove+'.v:count1<CR>
nnoremap <silent><C-w><M-h> :<C-u>execute 'tabmove-'.v:count1<CR>
nnoremap <silent><M-Q> :windo quit<CR>
nmap <silent><C-w>Q <M-Q>

" Maxmize the current window by duplicate it in a new tab
nnoremap <silent><C-w><M-t> <C-w>s<C-w>T
nnoremap <silent><C-w><C-t> <C-w>s<C-w>T
" Maxmize the current window or restore the previously window layout
nnoremap <silent><C-w>O :call <SID>win_toggle()<CR>
function! s:win_toggle() " {{{
  if exists('t:winrestcmd')
    execute t:winrestcmd
    unlet t:winrestcmd
  else
    let t:winrestcmd = winrestcmd()
    resize | vertical resize
    cal winrestcmd()
  endif
endfunction " }}}

" Exchange the current window with the previous one
nnoremap <C-w>X <C-w>W<C-w>x<C-w>w
" Exchange the current window with the {count}th window
" Note: This differs from <C-w>x in following ways:
" - The cursor would be on a different window.
" - Without a {count}, the first window is exchanged.
" - Mixed vertical and horizontal window splits are allowed.
nnoremap <silent><C-w>e :<C-u>execute 'buffer '.winbufnr(v:count1).'\|'
      \.v:count1.'wincmd w\|buffer '.winbufnr(0)<CR>
" Attach the current window bellow the last windows with the same width
nnoremap <silent><C-w>a :execute 'close\|$wincmd w\|belowright sbuffer '.bufnr('')<CR>

cabbrev <expr>v getcmdtype() == ':' && getcmdpos() == 2 ?
      \ 'vert'.v#setvar('g:_t', nr2char(getchar(0))).
      \   (_t == ' ' ? '' : "<BS><BS><BS>")._t : 'v'
cabbrev <expr>t getcmdtype() == ':' && getcmdpos() == 2 ? 'tab' : 't'

" Deal with terminal buffers
if has('nvim')
  tnoremap <M-w> <C-\><C-n><C-w>
  tnoremap <M-j> <C-\><C-n><C-w>w
  tnoremap <M-k> <C-\><C-n><C-w>W
  tnoremap <M-l> <C-\><C-n>gt
  tnoremap <M-h> <C-\><C-n>gT
  tnoremap <S-PageUp> <C-\><C-n><C-b>
  tnoremap <S-PageDown> <C-\><C-n><C-f>
  tnoremap <C-PageUp> <C-\><C-n><C-b>
  tnoremap <C-PageDown> <C-\><C-n><C-f>
  cabbrev <expr>st getcmdtype() == ':' && getcmdpos() == 3 ? 'new\|te' : 'st'
  cabbrev <expr>vt getcmdtype() == ':' && getcmdpos() == 3 ? 'vne\|te' : 'vt'
  cabbrev <expr>tt getcmdtype() == ':' && getcmdpos() == 3 ? 'tab new\|te' : 'tt'
  autocmd vimrc BufWinEnter,WinEnter term://* startinsert
  autocmd vimrc BufLeave term://* stopinsert
endif
" }}}
" Fold: "{{{
" Open the fold the cursor is in, recursively
nnoremap z<M-o> zczO

" Focus on a region using manual folding (mnemonic: pick)
nnoremap <silent>zp :set operatorfunc=<SID>fold_others<CR>g@
xnoremap <silent>zp :<C-u>call <SID>fold_others()<CR>
nnoremap <silent>zP :call <SID>fold_restore()<CR>
function! s:fold_others(...) " {{{
  let [line1, line2] = a:0 == 1 ? ["'[", "']"] : ["'<", "'>"]
  let b:fold_opts = [&fdm, &fdl, &fde]
  set fde=0 fdm=expr | redraw " disable existing folding
  set fdm=manual
  execute '1,'.line1.'-1fold|'.line2.'+1,$'.'fold'
endfunction
function! s:fold_restore()
  normal! zE
  let [&fdm, &fdl, &fde] = b:fold_opts
  normal! zvzz
endfunction " }}}

" Toggle fold methods
nnoremap <silent>cof :let &foldmethod = tolower(matchstr(
      \',mmanual,kmarker,iindent,ssyntax,eexpr,ddiff',
      \','.nr2char(getchar()).'\zs\a*\C'))\|set foldmethod<CR>
nmap <silent>zfm cof

" Don't screw up folds when inserting text that might affect them. Also improve
" speed by avoiding updating folds eagerly.
" autocmd vimrc InsertEnter * if !exists('w:vfdml') &&
"       \ &foldmethod != 'manual' && empty(&buftype) |
"       \ let w:vfdml=&foldmethod | set foldmethod=manual | endif
" However, restoring 'foldmethod' on InsertLeave would cause text under the
" cursor be closed if the inserted text creates a new fold level.
" autocmd vimrc InsertLeave * if exists('w:vfdml') && empty(&buftype) |
"       \ let &foldmethod=w:vfdml | unlet w:vfdml |
"       \ execute 'silent! normal! zo' |endif
"}}}
" Buffer:" {{{
set hidden autoread " autowrite

nnoremap <silent><M-b>d :bdelete<CR>
" Delete the current buffer without closing its window
nnoremap <silent><M-b>x :Bdelete<CR>
command! -bang Bdelete try |
      \ if buflisted('#') | buffer # | else | bprevious | endif |
      \ bdelete<bang> # |
      \ catch | bdelete<bang> | endtry
nnoremap <silent><M-b>w :bwipeout<CR>

cabbrev <expr>vb getcmdtype() == ':' && getcmdpos() == 3 ? 'vert sb' : 'vb'
cabbrev <expr>tb getcmdtype() == ':' && getcmdpos() == 3 ? 'tab sb' : 'tb'

" Delete all buffers in the buffer list except the current one
command! -bang BufOnly let _b = bufnr('') | let _f = &confirm |
      \ try | set noconfirm |
      \   silent! execute '1,'._b.'-bd<bang>|'._b.'+,$bd<bang>' |
      \ finally | let &confirm = _f | endtry

" Wipe out all unlisted buffers
command! BwipeoutUnlisted call vimrc#bufffer_wipe_unlisted()
" }}}
" File:" {{{
nnoremap <silent><M-f>w :write<CR>
nnoremap <silent><M-f><M-f>w :write!<CR>
nnoremap <silent><M-f>u :update<CR>
nnoremap <silent><M-f><M-f>u :update!<CR>
nnoremap <silent><M-f>a :wall<CR>
nnoremap <silent><M-f><M-f>a :wall!<CR>
nnoremap <silent><M-f>A :windo update<CR>
nnoremap <silent><M-f><M-f>A :windo update!<CR>
" Quick save and exit, useful when editing the shell command line
inoremap <M-z> <Esc>ZZ
nnoremap <silent><M-f>e :edit<CR>
nnoremap <silent><M-f><M-f>e :edit!<CR>
cnoremap <M-h> <C-r>=expand('%:h')<CR>/
nnoremap <M-f>f :filetype detect<CR>
nnoremap <M-f>F :silent! unlet b:did_ftplugin b:did_after_ftplugin<Bar>filetype detect<CR>
nnoremap <M-f>c :checktime<CR>
" Switch to the alternative buffer
nnoremap <silent><M-a> :buffer #<CR>
if has('nvim')
  tnoremap <silent><M-a> <C-\><C-n>:buffer #<CR>
endif
nnoremap <silent><C-W><M-s> :sbuffer #<CR>
nnoremap <silent><C-W><M-v> :vert sbuffer #<CR>

" Find a file in 'path'
cabbrev <expr>fi getcmdtype() == ':' && getcmdpos() == 3 ? 'fin' : 'fi'
cabbrev <expr>vf getcmdtype() == ':' && getcmdpos() == 3 ? 'vert sf' : 'vf'
cabbrev <expr>tf getcmdtype() == ':' && getcmdpos() == 3 ? 'tab sf' : 'tf'

" Directories to search by `gf, :find, cd, lcd etc.`
" (dir of the current file, current dir, etc.)
let &g:path = '.,,~,'.$MYVIM.','.$MYVIM.'/after'
set cdpath=,,.,~
if has('vim_starting') && 0 == argc() && has('gui_running') && !g:l
  cd $HOME
endif

" Open a destination file of a link
cnoremap <M-g>l <C-\>e<SID>get_link_targets()<CR><CR>
function! s:get_link_targets() " {{{
  let [cmd; links] = split(getcmdline())
  for l in links
    let cmd .= ' '.fnamemodify(resolve(expand(l)), ':~:.')
  endfor
  return cmd
endfunction " }}}

" Easy access to vimrc files
Abbr cabbr <expr>v $MYVIMRC
Abbr cabbr <expr>b $MYBUNDLE
nnoremap <silent><M-f>v :execute 'Be' $MYVIMRC<CR>
nnoremap <silent><M-f>b :execute 'Be' $MYBUNDLE<CR>

" Switch to a file without reloading it
command! -nargs=1 -bang Be execute (buflisted(expand(<q-args>))?'b':
      \filereadable(expand(<q-args>))||<bang>0?'e':'Nop').' '.<q-args>

" Make the file '_' a scratch buffer
autocmd vimrc BufNewFile,BufReadPost _ set buftype=nofile nobuflisted bufhidden=hide
autocmd vimrc SessionLoadPost * silent! bwipeout! _

" Recognise a file's encoding in this order
" set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,latin1

set fileformats=unix,dos,mac " end-of-line formats precedence
set fileformat=unix " only for the initial unnamed buffer

set nowritebackup " write to symbolic files safely on windows
" }}}
" Completion:" {{{

" Practical interface to various kinds of completions
" {{{
" Hacker: `a<BS>` to make the selected entry inserted.
inoremap <expr><Tab> getline('.')[col('.')-2] =~# '\S' ?
      \ (pumvisible() ? '<C-n>' : '<C-x><C-p>a<BS><C-p>') : '<Tab>'
inoremap <expr><S-Tab> pumvisible() ? '<C-p>' : '<C-x><C-n>a<BS><C-n>'
" Remove built-in mappings
autocmd vimrc CmdwinEnter [:>] silent! iunmap <buffer><Tab>

inoremap <expr><M-n> pumvisible() ? ' <BS><C-n>' : '<C-n>'
inoremap <expr><M-p> pumvisible() ? ' <BS><C-p>' : '<C-p>'

" CTRL-X completion-sub-mode
" Mnemonic: Expand
imap <M-e> <C-x>
imap <M-x> <C-x>
for s:c in split('lnpkti]fdvuos', '\zs')
  execute 'inoremap <C-X>'.s:c.' <C-X><C-'.s:c.'>'
endfor
" Mnemonic: diGraph
inoremap <C-X>g <C-k>
" Mnemonic: omni-completion would show Help info
inoremap <M-h> <C-x><C-o>
" }}}

" Completion behavior tweak
" {{{
" Insert mode
" 'menuone': Omni-completion may show additinal info in the popup menu.
" 'longest': Applied to all except for <Tab>.
" 'preview': Showing extra info is useful for learning a language.
set completeopt=menuone,longest,preview
set infercase " auto-adjust case
set complete-=i " don't scan included files when do <C-n> or <C-p>
set pumheight=15 " max number of items to show in the popup menu

" Command-line mode
set wildcharm=<Tab> " the key to trigger wildmode expansion in mappings
set wildmenu wildmode=longest:full,full
silent! set wildignorecase " ignore case when completing file names/directories
" }}}

" Auto-reverse letter case in insert mode
inoremap <M-c> <C-R>=<SID>toggle(1)<CR>
inoremap <M-g>c <C-R>=<SID>toggle(2)<CR>
function! s:toggle(arg) " {{{
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
endfunction " }}}

" Make a command(e.g. `:h ...`) split vertically or in a new tab.
cnoremap <M-w>v <C-\>e'vert '.getcmdline()<CR><CR>
cnoremap <M-w>t <C-\>e'tab '.getcmdline()<CR><CR>
cmap <M-CR> <C-\>e'tab '.getcmdline()<CR><CR>

" Expand a mixed case command name
cnoremap <M-l> <C-\>e<SID>cmd_expand()<CR><Tab>
function! s:cmd_expand() " {{{
  let cmd = getcmdline()
  let [range, abbr] = [matchstr(cmd, '^\A*'), matchstr(cmd, '\a.*')]
  let parts = map(split(abbr, abbr =~ '\s' ? '\s' : '\zs'), 'toupper(v:val[0]).v:val[1:]')
  return range . join(parts, '*')
endfunction " }}}

" Abbreviations
Abbr abbr bs Bohr Shaw

" Type notated keys
noremap! <expr><M-v> <SID>special_key()
function! s:special_key() " {{{
  let c1 = v#getchar(1, 1)
  if empty(c1)
    return ''
  endif
  if strtrans(c1)[0] == '^'
    let c1_2 = strtrans(c1)[1]
    if c1_2 == 'i'
      return '<Tab>'
    elseif c1_2 == 'm'
      return '<CR>'
    elseif c1_2 == '['
      return '<Esc>'
    else
      return '<C-'.tolower(c1_2).'>'
    endif
  elseif has_key(s:keymap, c1) == 1
    return s:keymap[c1]
  endif
  let c2 = v#getchar(1, 1)
  if empty(c2)
    return ''
  endif
  let c2_ = has_key(s:keymap_sp, c2) ? s:keymap_sp[c2] : c2
  let cc = c1.c2
  if has_key(s:keymap, cc) == 1
    return s:keymap[cc]
  elseif c1 ==? 'f'
    let c2 = c2 == 0 ? 1.v#getchar() : c2
    return '<'.toupper(c1).c2.'>'
  elseif cc =~# 'c.'
    return '<C-'.(c2 =~# '\u' ? 'S-'.tolower(c2_) : c2_).'>'
  elseif cc =~# '[Cx].'
    return 'CTRL-'.toupper(c2)
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
      \' ':      '<Space>',
      \"\<BS>":  '<BS>',
      \"\<Left>":  '<Left>',
      \"\<Right>": '<Right>',
      \"\<Up>":    '<Up>',
      \"\<Down>":  '<Down>',
      \'<':      '<lt>',
      \'\':      '<Bslash>',
      \'|':      '<Bar>',
      \'bu':     '<buffer>',
      \'no':     '<nowait>',
      \'nw':     '<nowait>',
      \'nm':     '<nomodeline>',
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
" Concisely list the newest leafs in the tree of changes. Er... useless...
command! UndoList echo join(reverse(map(
      \ split(scriptease#capture('undolist'), '\n')[-8:],
      \ "substitute(v:val, '\\s\\+', ' ', 'g')")), ' |')

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
" Execute a macro repeatedly within a range of lines, similar a recursive macro
nnoremap <silent>@R :set operatorfunc=<SID>repeat_macro<CR>g@
function! s:repeat_macro(...) " {{{
  let r = v#getchar()
  if empty(r) | return | endif
  while line('.') <= line("']") && line('.') >= line("'[")
    execute 'normal @'.r
  endwhile
endfunction " }}}
" Record and execute a recursive macro
nnoremap <silent>9q :call <SID>rec_macro()<CR>
function! s:rec_macro() " {{{
  let r = v#getchar()
  if empty(r) | return | endif
  " Empty the register first
  execute 'normal! q'.r.'q'
  " Setup a temporary mapping to terminate and execute the macro
  execute printf("nnoremap q q:call setreg('%s', '@%s', 'a')<Bar>".
        \"try<Bar>execute 'normal @%s'<Bar>".
        \"finally<Bar>execute 'nunmap q'<Bar>endtry<CR>", r, r, r)
  execute 'normal! q'.r
endfunction " }}}
" Execute a macro without remapping
NXnoremap <expr> <silent> @N repeat(
      \ ':<C-U>normal! <C-R><C-R>'.nr2char(getchar()).'<CR>', v:count1)

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
" Spell:" {{{
" Enable spell checking for particular file types
autocmd vimrc FileType gitcommit,markdown,txt setlocal spell
if has('patch-7.4.088')
  set spelllang=en,cjk " skip spell check for East Asian characters
endif
set spellfile=$MYVIM/spell/en.utf-8.add
" Clean up spell files
command! SpellCleanup silent runtime spell/cleanadd.vim

" Dictionary files
let s:dictionary = $MYVIM.'/spell/dictionary-oald.txt'
if filereadable(s:dictionary)
  let &dictionary = s:dictionary
elseif !has('win32')
  set dictionary=/usr/share/dict/words
else
  set dictionary=spell " completion from spelling as an alternative
endif

" Thesaurus files
set thesaurus=$MYVIM/spell/thesaurus-mwcd.txt
"}}}
" Persistence:" {{{

" - Remember UPPER_CASE global variables
" - Max number of files in which marks are remembered (:oldfiles)
" - Paths for which no marks will be remembered
" - Max number of lines saved for each register
" - Maximum size of an item contents in KiB
" - viminfo(shada) file name
let &viminfo = "!,'1000,r".$TMP.',<1000,s100,'.
      \ 'n'.$MYVIM.'/tmp/'.(has('nvim')?'shada':'viminfo')
let _viminfo = &viminfo " for easy restoration

" Exclude options and mappings and be portable
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize,slash,unix
set viewoptions=folds,cursor,slash,unix

let &swapfile = g:l ? 0 : 1 " use a swapfile for the buffer
set undofile " undo history across sessions

" Set default paths of temporary files
let opts = {'directory': 'swap', 'undodir': 'undo', 'backupdir': 'backup'}
for [opt, val] in items(opts)
  let dir = $MYVIM.'/tmp/'.val
  if !isdirectory(dir) | silent! call mkdir(dir) | endif
  execute 'set' opt.'^='.dir
endfor
set viewdir=$MYVIM/tmp/view

" }}}
" Readline:" {{{
" Readline style insertion adjusted for Vim
" - https://github.com/tpope/vim-rsi
" - https://github.com/bruno-/vim-husk

" Recall older or more recent command-line from history, but the command matches
" the current command-line
cnoremap <M-p> <Up>
cnoremap <M-n> <Down>

" Move the cursor around one character (won't break undo)
if has('patch-7.4.849')
  inoremap <C-f> <C-g>U<Right>
  inoremap <C-b> <C-g>U<Left>
else
  " Trigger the CursorMovedI event
  inoremap <C-f> <C-c>la
  " Won't trigger the CursorMovedI event
  inoremap <C-b> <C-c>i
endif
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>
" Delete one character after the cursor
inoremap <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"

" Move the cursor around one word (break undo)
inoremap <M-f> <S-Right>
inoremap <M-b> <S-Left>
" Move the cursor around one WORD
inoremap <M-F> <C-o>W
inoremap <M-B> <C-o>B
" Delete one word (across lines) (won't break undo)
" Builtin <C-w> or <C-u> stops once at the start position of insert.
inoremap <M-BS> <Space><C-c>"_x"-cb
inoremap <M-d> <Space><C-c>"_x"-ce
" Delete one WORD
inoremap <C-w> <Space><C-c>"_x"-cB
inoremap <M-D> <Space><C-c>"_x"-cE

" Word like motions in Command mode differs that in Insert mode. They're more
" like in Shells so that less motions are needed to go to a specific position,
" though they are also less granular.
cnoremap <expr><M-f> <SID>word_fb("\<Right>")
cnoremap <expr><M-b> <SID>word_fb("\<Left>")
cnoremap <M-F> <S-Right>
cnoremap <M-B> <S-Left>
" Delete till a non-keyword
cnoremap <expr><M-BS> <SID>word_fb("\<BS>")
cnoremap <expr><M-d> <SID>word_fb("\<Del>")
" Delete till a space
cnoremap <expr><C-w> <SID>word_fb("\<BS>", 0)
cnoremap <expr><M-D> <SID>word_fb("\<Del>", 0)
function! s:word_fb(key, ...) " {{{
  let f = a:key == "\<Right>" || a:key == "\<Del>" ? 1 : 0
  let db = a:key == "\<Del>" || a:key == "\<BS>" ? 1 : 0
  let line = getcmdline()
  let pos = getcmdpos()
  let pat1 = a:0 == 0 ?
        \ f ?
        \   db ? '\W*\w+' : '\W*\w+\W*' :
        \   '\w+\W*' :
        \ f ? '\s*\S+' : '\S+\s*'
  let pat2 = '%'.pos.'c'
  let pos2 = match(line, '\v'.(f ? pat2.pat1.'\zs' : pat1.pat2)) + 1
  if db
    let @- = f ? line[pos-1:pos2-2] : line[pos2-1:pos-2]
  endif
  return (wildmenumode() ?  " \<BS>" : '').
        \ repeat(a:key, f ? pos2-pos : pos-pos2)
endfunction " }}}

" Move the cursor around the line
inoremap <C-A> <C-O>^
cnoremap <C-A> <Home>
inoremap <expr><C-e> pumvisible() ? "<C-e>" : "<End>"
" Delete all before the cursor (won't break undo)
inoremap <expr><C-u> "<Space><C-c>\"_xc".
      \(search('^\s*\%#', 'bnc', line('.')) > 0 ? '0' : '^')
cnoremap <expr><C-u> <SID>c_u()
function! s:c_u() " {{{
  let @- = getcmdline()[:getcmdpos()-2]
  return "\<C-U>"
endfunction " }}}
" Delete all after the cursor
inoremap <C-k> <Space><C-c>"_xC
cnoremap <expr><C-k> <SID>c_k()
function! s:c_k() " {{{
  let @- = getcmdline()[getcmdpos()-1:]
  return repeat("\<Del>", strlen(getcmdline()) - getcmdpos() + 1)
endfunction " }}}

" Paste the previous deleted text
inoremap <expr><C-y> pumvisible() ? "<C-y>" : "<C-r>-"
cnoremap <C-y> <C-r>-

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
endif
" }}}
" Appearance:" {{{
" Set background color based on day or night
if has('vim_starting')
  let s:hour = strftime('%H')
  let &background = s:hour < 17 && s:hour > 6 ?
        \ 'light' : 'dark'
endif

" List special or abnormal characters:" {{{
set list " show non-normal spaces, tabs etc.
if &encoding ==# 'utf-8' || &termencoding ==# 'utf-8'
  " No reliable way to detect putty
  let s:is_win_ssh = has('win32') || !empty($SSH_TTY)
  " Special unicode characters/symbols:
  " ¬ ¶ ⏎ ↲ ↪ ␣ ¨ ⣿ │ ░ ▒ ⇥ → ← ⇉ ⇇ ❯ ❮ » « ↓ ↑
  " ◉ ○ ● • · ■ □ ¤ ▫ ♦ ◆ ◇ ▶ ► ▲ ▸ ✚ ★ ✸ ✿ ✜ ☯ ☢ ❀ ✨ ♥ ♣ ♠
  let s:lcs = split(s:is_win_ssh ? '· · » « ▫' : '· ␣ ❯ ❮ ▫')
  let &showbreak = s:is_win_ssh ? '→' : '╰' " └ ∟ ╰ ╘ ╙ τ Ŀ
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
  " Use a highlight group User{N} to apply only the difference to StatusLine to
  " StatusLineNC
  set statusline=%1*%{Vmode()} " mode
  set statusline+=:%n " buffer number
  set statusline+=%{(&modified?'+':'').(&modifiable?'':'-').(&readonly?'=':'')}
  set statusline+=%*:%.30f " file path, truncated if its length > 30
  set statusline+=:%2*%Y " file type
  set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?':'.&fenc:''} " file encoding
  set statusline+=%{&ff!='unix'?':'.&ff:''} " file format
  " Git branch name
  let &statusline .= exists('*fugitive#head') ?
        \ "%{exists('b:git_dir')?':'.fugitive#head(7):''}" : ''
  " set statusline+=%{':'.matchstr(getcwd(),'.*[\\/]\\zs\\S*')}
  set statusline+=%{get(b:,'case_reverse',0)?':CAPS':''} " software caps lock
  set statusline+=%w%q " preview, quickfix
  set statusline+=%*%= " left/right separator
  set statusline+=%c:%l/%L:%P " cursor position, line percentage
endfunction
function! Vmode() "{{{
  let mode = mode()
  if mode ==# 'i'
    return 'INS'
  elseif mode ==# 'R'
    return 'REP'
  elseif mode ==# 't'
    return 'TERM'
  elseif mode =~# '[VS]'
    return mode.'L'
  elseif mode =~# "[\<C-v>\<C-s>]"
    return strtrans(mode)[1].'B'
  else
    return toupper(mode)
  endif
  return ''
endfunction "}}}
set noshowmode " hide the mode message on the command line
set fillchars+=stl::,stlnc:: " characters to fill the statuslines
execute (has('vim_starting')?'autocmd vimrc VimEnter * ':'').'call Vstatusline()'

" Status line highlight
autocmd vimrc ColorScheme * call <SID>hi()
function! s:hi() "{{{
  let [bt, bg, ft, fg, ftn, fgn,
        \ ft1, fg1, ft2, fg2, ft9, fg9] = &background == 'dark' ?
        \ ['237', '#3a3a3a', '214', '#ffaf00', '40', '#00d700',
        \   '123', '#87FFFF', '218', '#ffafdf', '252', '#d0d0d0'] :
        \ ['250', '#bcbcbc', '88', '#870000', '22', '#005f00',
        \   '21', '#0000ff', '92', '#8700d7', '235', '#262626']
  execute 'hi StatusLine term=bold cterm=bold ctermfg='.ft 'ctermbg='.bt
        \ 'gui=bold guifg='.fg 'guibg='.bg
  execute 'hi StatusLineNC term=NONE cterm=NONE ctermfg='.ftn 'ctermbg='.bt
        \ 'gui=NONE guifg='.fgn 'guibg='.bg
  execute 'hi User1 term=bold cterm=bold ctermfg='.ft1 'ctermbg='.bt
        \ 'gui=bold guifg='.fg1 'guibg='.bg
  execute 'hi User2 term=bold cterm=bold ctermfg='.ft2 'ctermbg='.bt
        \ 'gui=bold guifg='.fg2 'guibg='.bg
  execute 'hi User9 term=bold cterm=bold ctermfg='.ft9 'ctermbg='.bt
        \ 'gui=bold guifg='.fg9 'guibg='.bg
  hi! link TabLineSel StatusLine
  hi! link TabLine StatusLineNC
  hi! link TabLineFill StatusLineNC
endfunction "}}}
if !has('vim_starting')
  doautocmd <nomodeline> vimrc ColorScheme *
endif

" The status line for the quickfix window
autocmd vimrc FileType qf setlocal statusline=%t
      \%{strpart('\ '.get(w:,'quickfix_title',''),0,66)}%=\ %11.(%c,%l/%L,%P%)

" Use CTRL-G, G_CTRL-G to see file and cursor information manually
set ruler " not effective when 'statusline' is set
set rulerformat=%50(%=%m%r%<%f%Y\ %c,%l/%L,%P%)
" }}}

let &showtabline = g:l ? 1 : 2

if exists('$TMUX')
  " set titlestring=%{fnamemodify(getcwd(),\ ':~')}
  " autocmd vimrc FocusLost,VimLeavePre * set titlestring=
else
  set title " may not be able to be restored
  autocmd vimrc VimEnter * let &titlestring = matchstr(v:servername, '.vim.*\c').
        \ (g:l ? '(L)' : '').' '.'%{getcwd()}'
endif

" Make it easy to spot the cursor, especially for Gnome-terminal whose cursor
" color is not distinguishable.
set cursorline
" set cursorcolumn

" set number " print the line number in front of each line
set relativenumber " show the line number relative to the current line
set numberwidth=3 " minimal number(2) of columns to use for the line number

" Font, color, window size:" {{{
if has('vim_starting')
  if has('gui_running')
    let &guifont = has('win32') ? 'Consolas:h10' : 'Consolas 10'
    set lines=40 columns=88
    if !g:l " maximize the window
      if has('win32')
        autocmd vimrc GUIEnter * simalt ~x
      else
        set lines=400 columns=300
      endif
    endif
    set linespace=0
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
endif
" }}}
set showcmd "show partial commands in status line
" Show matching pairs like (), [], etc." {{{
" set showmatch matchtime=1 " highlighting in plugin/matchparen.vim is better
autocmd vimrc ColorScheme * hi MatchParen cterm=underline ctermbg=NONE ctermfg=NONE
      \ gui=underline guibg=NONE guifg=NONE
" Enable or disable it due to the cost of frequently executed autocmds
nnoremap <expr>c\m ':'.(exists('g:loaded_matchparen') ? 'NoMatchParen' : 'DoMatchParen')."<CR>"
" }}}
silent! set breakindent " indent wrapped lines
set linebreak " don't break a word when displaying wrapped lines
set colorcolumn=+1 " highlight column after 'textwidth'
set display+=lastline " ensure the last line is properly displayed
set guicursor+=a:blinkon0 " don't blink the cursor
" if has('multi_byte_ime')
"   highlight CursorIM guifg=NONE guibg=#007500
" endif
set guiheadroom=0 " occupy more screen space on X11
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
set history=10000 " maximum number of commands and search patterns to keep
set synmaxcol=999 " ignore further syntax items to avoid slow redrawing
silent! set cryptmethod=blowfish cm=blowfish2 " acceptable encryption
silent! set langnoremap " 'langmap' doesn't apply to characters resulting from a mapping
" Make 'cw' consistent with 'dw'
" onoremap <silent> w :execute 'normal! '.v:count1.'w'<CR>

" Join lines without any character or with specified characters in between
command! -range -nargs=? -bang Join execute
      \ 'keepp <line1>,'.(<line1> == <line2> ? <line2> : <line2>-1).
      \ 's/\s*\n\s*/'.(<bang>0 ? <q-args> : ' '.<q-args>.' ' )
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
nnoremap <silent><F11> :if has('win32') \|
      \ call libcallnr('gvimfullscreen.dll', "ToggleFullScreen", 0) \|
      \ elseif has('unix') \|
      \ call system('wmctrl -ir '.v:windowid.' -b toggle,fullscreen') \|
      \ endif<CR>
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
" Print the ASCII table in a split window
command! -nargs=? ASCII call ascii#print(<f-args>)
" }}}
" Write HELP docs
command! HelpWrite setlocal buftype= buflisted modifiable noreadonly |
      \ mapclear <buffer> | mapclear! <buffer> |
      \ silent! unlet b:did_ftplugin b:did_after_ftplugin | filetype detect |
      \ setlocal conceallevel=0 spell

let $MYVIMRCAFTER = (g:ported ? $MYVIM.'/' : $HOME.'/.').'vimrc.local'
if filereadable($MYVIMRCAFTER)
  execute 'silent source' $MYVIMRCAFTER
endif

if has('vim_starting')
  " Must be after setting 'rtp'
  filetype plugin indent on
  syntax enable
endif
" }}}

" vim:fdm=marker:
