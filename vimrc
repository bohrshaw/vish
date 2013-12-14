" Description: Vim core configuration.
" Author: Bohr Shaw <pubohr@gmail.com>

" Essential {{{1
set nocompatible

" A unified runtime path(Unix default)
set rtp=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

let mapleader = ' '
let maplocalleader = ','

" The character encoding used inside Vim (Set early to allow mappings start
" with the ALT key work properly.)
set encoding=utf-8

" Bundle configuration
source ~/.vim/vimrc.bundle

" Enable these after rtp setup, but as early as possible to reduce startup time.
filetype plugin indent on
syntax enable

" Options {{{1
" Set default paths of temporary files
let dir_list = {'swap': 'directory', 'undo': 'undodir', 'backup': 'backupdir'}
for [dir_name, set_name] in items(dir_list)
  let set_value = $HOME . '/.vim/tmp/' . dir_name
  if !isdirectory(set_value)
    silent! call mkdir(set_value)
  endif
  exec "set " . set_name . "^=" . set_value
endfor
set viewdir=~/.vim/tmp/view
set viminfo=!,'50,<50,s10,h,n$HOME/.vim/tmp/viminfo
set undofile " save undo history to disk when write a buffer

set ttimeout " time out on key codes
set ttimeoutlen=50 " key code delay (instant escape from Insert mode)

set autoread " automatically read a file that has changed on disk
set hidden " maybe set autowrite

set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,latin1 " help to determine a file encoding
set fileformats=unix,dos " end-of-line format precedence

set wildmenu wildmode=longest:full,full wildignorecase " command line completion
set complete-=i " don't scan included files for keyword completion

set incsearch " find as you type search
set ignorecase " case insensitive search
set smartcase " case sensitive when upper case characters present

set autoindent " indent at the same level of the previous line
set shiftwidth=4 " number of spaces to use for each step of (auto)indent
set shiftround " use multiple of shiftwidth to round when indenting with '<' and '>'
set tabstop=4 " number of spaces a tab displayed in
set softtabstop=4 " number of spaces used when press <Tab> or <BS>
set expandtab " expand a tab to spaces
set smarttab " make tab width equals shiftwidth

set ruler " show the cursor position (not effective when 'statusline' is set)
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)

set showmode " display the current mode
set showcmd " show partial commands in status line and
set showmatch " show matching brackets/parenthesis

" Exclude options and mappings in saved sessions and views
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize,slash,unix
set viewoptions=folds,cursor,unix,slash

set scrolloff=1 " minimum lines to keep above and below cursor
set sidescrolloff=5 " the minimal number of screen columns to keep around the cursor

set list " show non-normal spaces, tabs etc.
if !has('win32') && (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8')
  let &listchars = "tab:\u21e5 ,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u00b7"
else
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif
set linebreak " don't break a word when displaying wrapped lines

" set spell " check spell
if v:version == 704 && has('patch088') || v:version > 704
  set spelllang=en,cjk " skip spell check for East Asian characters
endif

set path=.,,~ " directories to search by 'gf', ':find', etc.
set cdpath=.,,~/workspaces " directories to search by ':cd', ':lcd'

set mouse=a " enable mouse in all modes
" set clipboard=unnamed " link unnamed register and OS clipboard:

set matchpairs+=<:> " character pairs used by '%'
runtime macros/matchit.vim " extended pair matching with '%'

" set number " print the line number in front of each line
" set relativenumber " show the line number relative to the current line

set history=50 " a larger number of commands and search patterns to remember
set tabpagemax=50 " allow more tabs

au VimEnter * set vb t_vb= " disable error beep and screen flash
set nowritebackup " write to symbolic files safely on windows
set confirm " prompt for an action instead of fail immediately
set winminheight=0 " the minimal height of a window
set colorcolumn=+1 " highlight column after 'textwidth'
set background=dark " assume a dark background for color schemes
set backspace=indent,eol,start " backspace through anything in insert mode
set nrformats-=octal " exclude octal numbers when using C-A or C-X
set nolazyredraw " don't redraw the screen while executing macros etc.
set cryptmethod=blowfish " acceptable encryption strength, remember :set viminfo=
set shortmess+=filmnrwxoOtTI " avoid all the hit-enter prompts caused by file messages
set display+=lastline " ensure the last line is properly displayed

" Mappings {{{1
" Note:
" * See :help index, :help map-which-keys
" * Always use low case letter for mappings containing the Alt key.
"   Because <A-K> is not the same as <A-k> for the terminal vim.

" Create a map in the normal and visual modes.
command! -nargs=1 NXnoremap nnoremap <args>| xnoremap <args>

" Map {{{2
" Map ';' to ':' to reduce keystrokes
NXnoremap ; :
NXnoremap z; q:
NXnoremap @; @:

" The substitution to ';' and ','
NXnoremap - ;
NXnoremap _ ,

" The counterpart to <CR>
NXnoremap <S-CR> -

" Switch tabs quickly
noremap <C-l> gt
noremap <C-h> gT
noremap gl gt
noremap gh gT
for n in range(1, 9)
  exe 'noremap ' . '<A-' . n . '> ' . n . 'gt'
endfor

" Move tabs
noremap gH :tabm -1<cr>
noremap gL :tabm +1<cr>
cabbrev tm tabm
cabbrev tmh tabm -1
cabbrev tml tabm +1

" Two maps enough for switching windows
noremap <C-j> <C-W>w
noremap <C-k> <C-W>W
noremap gj <C-W>w
noremap gk <C-W>W

" Be consistent with other operators
nnoremap Y y$

" Make repeating last substitution keep the flags
NXnoremap & :&&<cr>

" Wrapped lines goes down/up to next row, rather than next line in file.
nnoremap j gj
nnoremap k gk

" Allow the `.` to execute once for each line of a visual selection.
vnoremap . :normal .<CR>

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Easier horizontal scrolling
noremap zl zL
noremap zh zH

" Open help in a new tab
command! -nargs=? -complete=help H tab h <args>
command! -nargs=? -complete=help Hv vert h <args>

" Open help in a vertical window
cabbrev vh vert h

" Print the change list
cabbrev chs changes

" Map! {{{2
" Don't move the cursor when pressing `i` and `<Esc>`
" inoremap <Esc> <Esc>`^

" Split a buffer vertically
cabbrev vsb vert sb

" Edit a file in a new tab
cabbrev te tabe

" Close a tab
cabbrev tc tabc

" Edit a buffer in a new tab
cabbrev tb tab sb

" Open the command-line window
set cedit=<C-G>

" Break the undo sequence
inoremap <c-u> <c-g>u<c-u>

" Recall older or more recent command-line from history, whose beginning matches
" the current command-line.
cnoremap        <C-P> <Up>
cnoremap        <C-N> <Down>

" Move the cursor around the line
inoremap        <C-A> <C-O>^
inoremap   <C-X><C-A> <C-A>
cnoremap        <C-A> <Home>
cnoremap   <C-X><C-A> <C-A>
inoremap <expr> <C-E> col('.')>strlen(getline('.'))?"\<Lt>C-E>":"\<Lt>End>"

" Move the cursor around one word
noremap!        <M-f> <S-Right>
noremap!        <M-b> <S-Left>

" Move the cursor around one character
inoremap <expr> <C-F> col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"
cnoremap        <C-F> <Right>
noremap!        <C-B> <Left>

" Delete one word after the cursor
inoremap        <M-d> <C-O>dw
cnoremap        <M-d> <S-Right><C-W>

" Delete one character after the cursor
inoremap <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"

" Transpose two characters around the cursor
noremap! <expr> <SID>transposition getcmdpos()>strlen(getcmdline())?"\<Left>":getcmdpos()>1?'':"\<Right>"
noremap! <expr> <SID>transpose "\<BS>\<Right>".matchstr(getcmdline()[0 : getcmdpos()-2], '.$')
cmap   <script> <C-T> <SID>transposition<SID>transpose

" Appearance {{{1
" if has('multi_byte_ime')
"   highlight CursorIM guifg=NONE guibg=Green
" endif

" Starline: A quiet Vim Status line
set laststatus=2 " always display statusline
" File modified flag, read only flag, preview flag, quickfix flag
set statusline=%m%r%w%q
" File name (truncate if too long)
set statusline+=%<%f
" File encoding
set statusline+=\ %{&fenc==''?'':','.&fenc}
" File format
set statusline+=%{&ff==''?'':','.&ff}
" File type
set statusline+=%{&ft==''?'':','.&ft}
" Software caps lock status
set statusline+=\ %{exists('*CapsLockSTATUSLINE')?CapsLockSTATUSLINE():''}
" Left/Right separator
set statusline+=%=
" Custom git branch status
set statusline+=%{exists('*fugitive#head')&&fugitive#head(7)!=''?fugitive#head(7):''}
" The current working directory
set statusline+=\ %{substitute(getcwd(),'.*[\\/]','','')}
" Cursor position and line percentage (with a minimum width)
set statusline+=\ %14(%c%V,%l/%L,%p%%%)

" GUI vs Terminal {{{1
if has('gui_running')
  if has('win32')
    set guifont=Consolas:h10
    au GUIEnter * simalt ~x " max window
  else
    set guifont=Consolas\ 10
    set lines=250 columns=200
  endif

  set guioptions=

  " Change the default working directory to HOME
  if 0 == argc() | cd $HOME | endif
else
  " Make the Meta(Alt) key mappable in terminal. But some characters(h,j,k,l...)
  " often typed after pressing <Esc> are not touched, so not mappable.
  for c in split('qwertyasdfgzxcvbm', '\zs')
    exe "set <M-".c.">=\e".c
  endfor

  " Assume xterm supports 256 colors
  if &term =~ 'xterm' | set term=xterm-256color | endif

  " Disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " See also http://snk.tuxfamily.org/log/vim-256color-bce.html
  if &term =~ '256col' | set t_ut= | endif

  " Allow color schemes do bright colors without forcing bold.
  if &t_Co == 8 && &term !~ '^linux' | set t_Co=16 | endif
endif

" vim:ft=vim tw=80 et sw=2 fdm=marker cms="\ %s nowrap:
