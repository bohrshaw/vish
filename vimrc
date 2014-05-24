" Description: Vim core configuration.
" Author: Bohr Shaw <pubohr@gmail.com>

" TIPS:
" Less is more!
" Analyse startup performance by `vim --startuptime profile`

" Foundation: {{{1

if !exists('g:loaded_vimrc')
  silent! source ~/.vimrc.local " override system vimrc

  let g:l = $VIML && !get(g:, 'h') || get(g:, 'l') " lightweight Vim or not

  set nocompatible " make Vim behave in a more useful way
  set rtp^=$HOME/.vim rtp+=$HOME/.vim/after " be portable

  " let mapleader = "\r" " replace <Leader> in a map
  let maplocalleader = 'g\' " replace <LocalLeader> in a map

  " The character encoding used inside Vim (Set early to allow mappings start
  " with the ALT key work properly.)
  if has('gui_running') || $termencoding ==? 'utf-8'
    set encoding=utf-8
  endif

  " Skip sourcing '$VIMRUNTIME/menu.vim'. (before filetype/syntax setup)
  set guioptions=M

  " Commands for defining mappings in several modes
  command! -nargs=1 NXnoremap nnoremap <args><Bar> xnoremap <args>
  " Allow chained commands, but also check for a " to start a comment
  command! -bar -nargs=1 NXInoremap nnoremap <args><Bar> xnoremap <args><Bar>
              \ inoremap <args>

  runtime vimrc.bundle " bundle configuration
  BundleInject " inject bundle paths to 'rtp'

  " Enable these immediately after setting 'rtp' to avoid problems and reduce
  " startup time. (The Syntax event would be unavailable if syntax is off.)
  filetype plugin indent on
  syntax enable
endif

" Define or switch to an auto-command group and clean it
execute 'augroup vimrc| autocmd!'

" ---------------------------------------------------------------------
" Options: {{{1

" View and set all options by :opt[ions]
" See https://github.com/tpope/vim-sensible/blob/master/plugin/sensible.vim for
" a minimal sensible default.

" set timeoutlen=3000 " mapping delay
set ttimeoutlen=50 " key code delay (instant escape from Insert mode)

set autoindent " indent at the same level of the previous line
set shiftwidth=4 " number of spaces to use for each step of (auto)indent
set shiftround " round indent to multiple of 'shiftwidth'
set tabstop=4 " number of spaces a tab displayed in
set softtabstop=4 " number of spaces used when press <Tab> or <BS>
set expandtab " expand a tab to spaces
set smarttab " <Tab> in front of a line inserts blanks according to 'shiftwidth'

set matchpairs+=<:> " character pairs matched by '%'
runtime macros/matchit.vim " extended pair matching with '%'
set incsearch " show matches when typing the search pattern
set ignorecase " case insensitive in search patterns and command completion
set smartcase " case sensitive only when up case characters present
set winminheight=0 " the minimal height of a window
set scrolloff=1 " minimum lines to keep above and below cursor
set sidescrolloff=5 " minimal number of screen columns to keep around the cursor
set history=1000 " maximum number of commands and search patterns to keep
" set tabpagemax=50 " maximum number of tab pages to be opened by some commands
set confirm " prompt for an action instead of fail immediately
set backspace=indent,eol,start " backspace through anything in insert mode
silent! set formatoptions+=j " remove a comment leader when joining lines
set nrformats-=octal " exclude octal numbers when using C-A or C-X
set lazyredraw " don't redraw the screen while executing macros, etc.
set synmaxcol=999 " ignore further syntax items to avoid slow redrawing
set cryptmethod=blowfish " acceptable encryption strength
set shortmess=aoOtTI " avoid all the hit-enter prompts caused by file messages
set display+=lastline " ensure the last line is properly displayed
" autocmd GUIEnter * set vb t_vb= " disable error beep and screen flash
" set mouse= " disable mouse in all modes to tolerate Touchpad mis-touch
set guioptions+=c " use a console dialog for confirmation instead of a pop-up
" Sync visual mode selection with the selection register(*) in supported GUI
execute has('gui_gtk')||has('gui_motif')||has('gui_athena') ? 'set go+=a' : ''
" set clipboard+=unnamed " sync the selection register with the unnamed register

set wildmenu wildmode=longest:full,full " command line completion mode
silent! set wildignorecase " ignore case when completing file names/directories
set completeopt=menu,longest " insert-completion mode
set complete-=i " don't scan included files when insert-completing by <C-N/P>
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
autocmd FileType gitcommit,markdown,txt setlocal spell
if v:version == 704 && has('patch088') || v:version > 704
  set spelllang+=cjk " skip spell check for East Asian characters
endif

set autoread " auto-read a file changed outside of Vim
" set autowrite " auto-write a modified file when switching buffers
set nowritebackup " write to symbolic files safely on windows
set hidden " hide a modified buffer without using '!' when it's abandoned
" Recognise a file's encoding in this order
" set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,latin1
set fileformats=unix,dos,mac " end-of-line formats precedence
set fileformat=unix " only for the initial unnamed buffer

" Don't move the cursor to the line start when switching buffers
autocmd BufLeave * set nostartofline |
      \ autocmd vimrc CursorMoved * set startofline | autocmd! vimrc CursorMoved
" Jump to the last known position in a file just after opening it
autocmd BufRead * silent! execute 'normal! g`"'

let &swapfile = l ? 0 : 1 " use a swapfile for the buffer
set undofile
let &viminfo = "!,'50,<50,s10,h,n$HOME/.vim/tmp/viminfo"
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

set path=.,,~ " directories to search by 'gf', ':find', etc.
set cdpath=.,,~/workspaces " directories to search by ':cd', ':lcd'

if executable('ag')
  set grepprg=ag\ --column " --nocolor --nobreak implicitly
  set grepformat^=%f:%l:%c:%m " the output format when not running interactively
elseif executable('ack')
  set grepprg=ack\ --column
  set grepformat^=%f:%l:%c:%m
endif

if !exists('g:loaded_vimrc') && 0 == argc() && has('gui_running') && !l
  cd $HOME
endif

" Make the file '_' a scratch buffer
autocmd BufNewFile,BufReadPost _ set buftype=nofile nobuflisted bufhidden=hide
autocmd SessionLoadPost * silent! bwipeout! _

" ---------------------------------------------------------------------
" Mappings: {{{1

" A single mapping is easy to define, while the whole mapping scheme should be
" considered carefully to be consistent, intuitive, convenient and accessible!
"
" Potentially unused keys: "\ <Space> <CR> <BS> Z Q R S X _ !"
" Keys waiting for a second key: "f t d c g z v y m q ' [ ]"
" Special keys like <CR>, <BS> are often mapped solely, as well as 'q' which is
" often mapped to quit a window.
" <Tab>/<C-I>, <CR>/<C-M>, <Esc>/<C-[> are pairs of exactly same keys.
" <A-x> is <Esc>x in console Vim.
" Caps Lock, <C-1>, <C-S-1> etc. are not mappable.
" Use capital letters in keys like <C-J> for readability.
" See related help topics: index, map-which-keys

if !has('gui_running')
  " Make the Meta(Alt) key mappable in terminal. But some characters(h,j,k,l...)
  " often typed after pressing <Esc> are not touched, so not mappable.
  " for c in split('qwertyasdfgzxcvbm', '\zs')
  "   execute "set <M-".c.">=\e".c
  " endfor
endif

" Free a somewhat-excess home-row key to act as a mapping leader. But don't
" disable it to be able to use {count}s.
" NXnoremap s <Nop>
" Avoid entering the crappy Ex mode
NXnoremap Q <Nop>

" Enter command line at the speed of light
NXnoremap <Space> :
NXnoremap z<Space> q:
NXnoremap z/ q/
NXnoremap @<Space> @:

" Repeat last change on each line in a visual selection
xnoremap . :normal! .<CR>
" Execute a macro on each one in {count} lines
nnoremap <silent> @. :call <SID>macro()<CR>
function! s:macro() range
  execute a:firstline.','.a:lastline.'normal! @'.nr2char(getchar())
endfunction
" Execute a macro on each line in a visual selection
xnoremap <silent> @ :<C-u>execute ":'<,'>normal! @".nr2char(getchar())<CR>

" Search the literal text of a visual selection
xnoremap * :<C-u>call <SID>v_search('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>v_search('?')<CR>?<C-R>=@/<CR><CR>
function! s:v_search(dir)
  let temp = @s
  normal! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:dir.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

" Yank till the line end instead of the whole line
nnoremap Y y$
" Yank to GUI/system clipboard
NXnoremap gy "+y
" Make 'cw' consistent with 'dw'
onoremap <silent> w :execute 'normal! '.v:count1.'w'<CR>
" Mark a single line in character-wise visual mode
nnoremap vv ^vg_
" Substitute in an visual area
xnoremap cs :s/\%V
" Keep the flags when repeating last substitution
NXnoremap & :&&<CR>
" Deleting to the black hole register
NXnoremap R "_d

" The leader key of window related mappings
" NXnoremap S <C-W>
" Go to the below/right or above/left window
NXnoremap gj <C-W>w
NXnoremap gk <C-W>W
NXnoremap gl <C-W>l
NXnoremap gh <C-W>h
" Move through display lines
NXnoremap tj gj
NXnoremap tk gk
" Split a window vertically with the alternate file
NXnoremap <C-W><C-^> :vsplit #<CR>

" Go to [count] tab pages forward or back
NXnoremap <silent> tl :<C-U>execute repeat('tabn\|', v:count1-1).'tabn'<CR>
NXnoremap th gT
" Go to {count}th tab page
for n in range(1, 9)
  execute 'NXnoremap '.'<M-'.n.'> '.n.'gt'
endfor

" Edit a file in the same directory of the current file
NXnoremap <leader>ee :e <C-R>=expand('%:h')<CR>/
NXnoremap <leader>es :sp <C-R>=expand('%:h')<CR>/
NXnoremap <leader>ev :vs <C-R>=expand('%:h')<CR>/
NXnoremap <leader>et :tabe <C-R>=expand('%:h')<CR>/

" Mappings for the cmdline window
autocmd CmdwinEnter * noremap <buffer> <F5> <CR>q:|
      \ NXInoremap <buffer> <nowait> <CR> <CR>|
      \ NXInoremap <buffer> <C-C> <C-C><C-C>

" Mappings/options for a quickfix/location window
autocmd FileType qf nnoremap <buffer> <nowait> <CR> <CR>|
      \ nnoremap <buffer> q <C-W>c|
      \ nnoremap <buffer> <C-V> <C-W><CR><C-W>H|
      \ nnoremap <buffer> <C-T> <C-W><CR><C-W>T

" Mappings for diff mode
xnoremap <silent> do :execute &diff ? "'<,'>diffget" : ''<CR>
xnoremap <silent> dp :execute &diff ? "'<,'>diffput" : ''<CR>
nnoremap <silent> du :execute &diff ? 'diffupdate' : ''<CR>
" Switch off diff mode and close other diff panes
nnoremap dO :diffoff \| windo if &diff \| hide \| endif<CR>

" Reverse the selected text
xnoremap cR c<C-O>:set revins<CR><C-R>"<Esc>:set norevins<CR>

" Pseudo global marks for jumping to the last position in a file
NXnoremap <silent> 'V :let _f = expand('~/.vim/vimrc')\|
            \ execute (buflisted(_f)?'b ':'e ') . _f<CR>
NXnoremap <silent> 'B :let _f = expand('~/.vim/vimrc.bundle')\|
            \ execute (buflisted(_f)?'b ':'e ') . _f<CR>

" ---------------------------------------------------------------------
" Mappings!: {{{1

" Open the command-line window
set cedit=<C-G>

" A smart and light <Tab> to do insert-completion
inoremap <expr> <Tab> getline('.')[col('.')-2] !~ '^\s\?$' \|\| pumvisible()
      \ ? '<C-N>' : '<Tab>'
inoremap <expr> <S-Tab> pumvisible() \|\| getline('.')[col('.')-2] !~ '^\s\?$'
      \ ? '<C-P>' : '<Tab>'
autocmd CmdwinEnter * inoremap <expr> <buffer> <Tab>
      \ getline('.')[col('.')-2] !~ '^\s\?$' \|\| pumvisible()
      \ ? '<C-X><C-V>' : '<Tab>'

" Shortcuts of insert-completion in CTRL-X mode
inoremap <C-X>l <C-X><C-L>
inoremap <C-X>n <C-X><C-N>
inoremap <C-X>p <C-X><C-P>
inoremap <C-X>k <C-X><C-K>
inoremap <C-X>t <C-X><C-T>
inoremap <C-X>i <C-X><C-I>
inoremap <C-X>] <C-X><C-]>
inoremap <C-X>f <C-X><C-F>
inoremap <C-X>d <C-X><C-D>
inoremap <C-X>v <C-X><C-V>
inoremap <C-X>u <C-X><C-U>
inoremap <C-X>o <C-X><C-O>
inoremap <C-Z> <C-X><C-O>

" Break the undo sequence
" inoremap <C-U> <C-G>u<C-U>

" Recall older or more recent command-line from history, but the command matches
" the current command-line
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Move the cursor around the line
inoremap <C-A> <C-O>^| inoremap <C-X><C-A> <C-A>
cnoremap <C-A> <Home>| cnoremap <C-X><C-A> <C-A>
inoremap <C-E> <End>

" Move the cursor around one word
noremap! <M-f> <S-Right>
noremap! <M-b> <S-Left>

" Move the cursor around one character
inoremap <expr> <C-F> col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"
cnoremap <C-F> <Right>
noremap! <C-B> <Left>

" Delete one word after the cursor
inoremap <M-d> <C-O>dw
cnoremap <M-d> <S-Right><C-W>

" Delete one character after the cursor
inoremap <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"

" Transpose two characters around the cursor
noremap! <expr> <SID>transposition getcmdpos() > strlen(getcmdline()) ?
      \ "\<Left>" : getcmdpos()>1 ? '' : "\<Right>"
noremap! <expr> <SID>transpose "\<BS>\<Right>"
      \ . matchstr(getcmdline()[0 : getcmdpos()-2], '.$')
cmap <script> <C-T> <SID>transposition<SID>transpose

" ---------------------------------------------------------------------
" Commands: {{{1

" Calculate the time spending on executing commands
command! -nargs=1 -count=1 -complete=command Time
            \ call vimrc#time(<q-args>, <count>)

" Join lines with characters in between
command! -range -nargs=? Join <line1>,<line2>-1s/\s*\n\s*/<args>/

" Remove trailing white spaces
command! Trim let _p=getpos('.')| keepj keepp %s/\s\+$//| call setpos('.',_p)

" Substitute in a visual area
command! -range -nargs=1 SV s/\%V<args>

" Remove duplicate, consecutive lines (:sort /.\_^/ u)
command! -range=% Uniqc <line1>,<line2>g/\v^(.*)\n\1$/d
" Remove duplicate, nonconsecutive and nonempty lines (g/\v^(.+)$\_.{-}^\1$/d)
command! -range=% Uniqn <line1>,<line2>g/^./
      \ if search('^\V'.escape(getline('.'),'\').'\$', 'bW') |
      \ delete | endif <NL> silent! normal! ``

" Source a range of lines
command! -bar -range Source <line1>,<line2>yank z<Bar>
      \ let @z = substitute(@z, '\n\s*\\', '', 'g')<Bar>@z<CR>

" Execute a command in each buffer in the quickfix or location list
command! -nargs=1 -complete=command Qdo call vimrc#errdo('q', <q-args>)
command! -nargs=1 -complete=command Ldo call vimrc#errdo(<q-args>)

" Delete all buffers in the buffer list
command! BdAll execute '1,'.bufnr('$').'bdelete'
" Delete all buffers in the buffer list except the current one
command! BufOnly let nc = bufnr('%') |let nl = bufnr('$') |
      \ silent! execute nc > 1 ? '1,'.(nc-1).'bdelete |' : ''
      \ nl > nc ? (nc+1).','.nl.'bdelete' : ''
" Wipe out all unlisted buffers
command! BwUnlisted call vimrc#bufffer_wipe_unlisted()

" Create a path
command! -nargs=? -complete=dir Mkdir call vimrc#mkdir(<q-args>)

" Execute an external command silently
command! -nargs=1 -complete=shellcmd Silent call system(<q-args>)

" Diff with another file
command! -nargs=? -complete=buffer DiffWith call vimrc#diffwith(<f-args>)

" Clear undo history (:w to clear the undo file if presented)
command! -bar UndoClear execute 'set undolevels=-1 |move -1 |'.
      \ 'let [&modified, &undolevels] = ['.&modified.', '.&undolevels.']'

" Append a mode line
command! AppendModeline call vimrc#appendModeline()

" Search via Google
command! -nargs=1 Google call netrw#NetrwBrowseX(
      \ "http://www.google.com.hk/search?q=".expand("<args>"),0)

" Clear the current quickfix list
command! -bar Cclear call setqflist([])
" Grep through all buffers
command! -nargs=1 BufGrep cexpr [] | bufdo vimgrepadd <args> %
" command! -nargs=1 BufGrep cexpr [] | mark Z |
"       \ execute "bufdo silent! g/<args>/caddexpr
"       \ expand('%').':'.line('.').':'.getline('.')" | normal `Z
" Grep using 'ag' or 'ack' without affecting 'grepprg' and 'grepformat'
command! -bar -nargs=+ -complete=file Ag call grep#grep('ag', <q-args>)
command! -bar -nargs=+ -complete=file Ack call grep#grep('ack', <q-args>)
command! -nargs=+ -complete=command Help call grep#help(<q-args>)
command! -nargs=+ -complete=command Helpgrep call grep#help('grep '.<q-args>)

" Calculate words frequency
command! -range=% WordFrequency <line1>,<line2>call vimrc#word_frequency()
" Count anything in a range of lines
command! -range=% -nargs=? Count echo vimrc#count
      \(<q-args>, <line1>, <line2>) | normal ``
" Calculate the total lines of source code minus blank lines and comment lines.
command! -range=% SLOC echo vimrc#count
      \('^[^' . &cms[0] . ']', <line1>, <line2>) | normal ``

" Mystify texts
command! Mystify call misc#mystify()

" ---------------------------------------------------------------------
" Abbreviations: {{{1

" Open help in a vertical window or a new tab
cabbrev hv vert h
cabbrev ht tab h

" Edit a file in a new tab
cabbrev te tabe
" Split a buffer in a vertical window or a new tab
cabbrev vsb vert sb
cabbrev tb tab sb

" Print the change list or mark list
cabbrev chs changes
cabbrev ms marks

" Tab related
cabbrev tm tabm
cabbrev tmh tabm -1
cabbrev tml tabm +1
cabbrev tc tabc

" Get the relative path of the current file
cabbrev %% <C-R>=expand('%:h').'/'<CR>

" ---------------------------------------------------------------------
" Appearance: {{{1

" set number " print the line number in front of each line
set relativenumber " show the line number relative to the current line
set numberwidth=3 " minimal number(2) of columns to use for the line number
set nowrap " only part of long lines will be displayed
set linebreak " don't break a word when displaying wrapped lines

set list " show non-normal spaces, tabs etc.
" Special characters: ¬¶⏎↲↪ •·▫¤␣¨ ░▒ ▸⇥→←⇉⇇»«↓↑
if &encoding ==# 'utf-8' || &termencoding ==# 'utf-8'
  let s:lcs = ['→\ ', '·', '»', '«', '▫'] " ['⇥\ ', '␣', '⇉', '⇇', '▫']
else
  let s:lcs = ['>\ ', '-', '>', '<', '+']
endif
execute 'set listchars=tab:'.s:lcs[0].',trail:'.s:lcs[1]
      \ .',extends:'.s:lcs[2].',precedes:'.s:lcs[3].',nbsp:'.s:lcs[4]
" Avoid showing trailing whitespace when in insert mode
execute 'autocmd InsertEnter * set listchars-=trail:'.s:lcs[1]
execute 'autocmd InsertLeave * set listchars+=trail:'.s:lcs[1]

set showcmd "show partial commands in status line
" set showmatch matchtime=3 "show matching brackets, better using matchparen.vim
set colorcolumn=+1 " highlight column after 'textwidth'

" A concise status line named "Starline"
set laststatus=2 " always display the status line
function! s:stl()
  set statusline=%m%.30f " modified flag, file name(truncated if length > 30)
  set statusline+=\ %H%W%q%R%Y " help, preview, quickfix, read-only, filetype
  set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?','.&fenc:''} " file encoding
  set statusline+=%{&ff!='unix'?','.&ff:''} " file format
  " Git branch name
  let &statusline .= exists('*fugitive#head') ?
        \ "%{exists('b:git_dir')?','.fugitive#head(7):''}" : ''
  " set statusline+=%{','.matchstr(getcwd(),'.*[\\/]\\zs\\S*')}
  " Software caps lock
  let &statusline .= exists('*CapsLockSTATUSLINE')?"%{CapsLockSTATUSLINE()}":''
  let &statusline .= ' %<'.repeat('=', 200).' ' " filler
  set statusline+=%= " left/right separator
  set statusline+=%c,%l/%L,%P " cursor position, line percentage
endfunction
" Ensure all plugins are loaded before setting 'statusline'
execute (exists('g:loaded_vimrc')?'':'autocmd VimEnter * ').'call s:stl()'

" The status line for the quickfix window
autocmd FileType qf setlocal statusline=%t
      \%{strpart('\ '.get(w:,'quickfix_title',''),0,66)}%=\ %11.(%c,%l/%L,%P%)

" Use CTRL-G, G_CTRL-G to see file and cursor information manually
set ruler " not effective when 'statusline' is set
set rulerformat=%50(%=%m%r%<%f%Y\ %c,%l/%L,%P%)

" set tabline=
" set titlestring=

if !exists('g:loaded_vimrc')
  if has('gui_running')
    if has('win32')
      set guifont=Consolas:h10
      autocmd GUIEnter * simalt ~x " maximize window
    else
      set guifont=Consolas\ 10
      set lines=250 columns=200
    endif
  else
    " Assume xterm supports 256 colors
    if &term =~ 'xterm' | set term=xterm-256color | endif

    " Disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    " See also http://snk.tuxfamily.org/log/vim-256color-bce.html
    if &term =~ '256col' | set t_ut= | endif

    " Allow color schemes do bright colors without forcing bold.
    if &t_Co == 8 && &term !~ '^linux' | set t_Co=16 | endif
  endif

  set background=dark " assume a dark background for color schemes
  if has('gui_running') || &t_Co == 256
    execute 'color '.(g:l ? 'last256' : 'solarized')
  else
    color kolor
  endif
endif

" if has('multi_byte_ime')
"   highlight CursorIM guifg=NONE guibg=#007500
" endif

" ---------------------------------------------------------------------
" Footer: {{{1

execute 'augroup END'
let g:loaded_vimrc = 1

" vim:ft=vim tw=80 et sw=2 fdm=marker cms="\ %s nowrap spell:
