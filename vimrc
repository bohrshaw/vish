" Description: Vim core configuration.
" Author: Bohr Shaw <pubohr@gmail.com>

" TIPS:
" View and set all options by :opt[ions]
" Analyse startup performance by `vim --startuptime profiling`

" Foundation {{{1
if !exists('g:loaded_vimrc')
  set nocompatible " make Vim behave in a more useful way

  " Light weight Vim or not
  let l = exists('l') ? l : 0

  " A unified runtime path(Unix default)
  set rtp=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

  let mapleader = ' ' " replace <Leader> in a map
  let maplocalleader = '\' " replace <LocalLeader> in a map

  " The character encoding used inside Vim (Set early to allow mappings start
  " with the ALT key work properly.)
  set encoding=utf-8

  " Remove all visual distraction and don't source "$VIMRUNTIME/menu.vim" to
  " reduce startup time. Must be before syntax or filetype setup.
  set guioptions=M

  " Commands for defining mappings in several modes
  command! -nargs=1 NXnoremap nnoremap <args><Bar> xnoremap <args>
  " Allow chained commands, but also check for a " to start a comment
  command! -bar -nargs=1 NXInoremap nnoremap <args><Bar> xnoremap <args><Bar> inoremap <args>

  " Bundle configuration and set the bundle list 'g:bundles'
  source ~/.vim/vimrc.bundle

  " Set runtime path
  let bundle_dirs = map(bundles, 'v:val[stridx(v:val,"/")+1:]')
  call pathway#inject('bundle', bundle_dirs)

  " Enable these after rtp setup, but as early as possible to reduce startup time.
  filetype plugin indent on
  syntax enable
endif

" Define an autocmd group and empty it
augroup vimrc | autocmd!
augroup END

" ---------------------------------------------------------------------
" Options {{{1
" Set default paths of temporary files
let opts = {'directory': 'swap', 'undodir': 'undo', 'backupdir': 'backup'}
for [opt, dir] in items(opts)
  let value = $HOME . '/.vim/tmp/' . dir
  if !isdirectory(value) | silent! call mkdir(value) | endif
  execute "set " . opt . "^=" . value
endfor
set viewdir=~/.vim/tmp/view

let &swapfile = l ? 0 : 1 " use a swapfile for the buffer
let &undofile = l ? 0 : 1 " persistent undo
let &viminfo = "!,'50,<50,s10,h,n$HOME/.vim/tmp/viminfo"
" Exclude options and mappings and be portable
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize,slash,unix
set viewoptions=folds,cursor,slash,unix

set ttimeout " time out on key codes
set ttimeoutlen=50 " key code delay (instant escape from Insert mode)

set autoread " auto-read a file changed outside of Vim
" set autowrite " auto-write a modified file when switching buffers
set hidden " hide a modified buffer without using '!' when it's abandoned

set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,latin1 " help to determine a file encoding
set fileformats=unix,dos " end-of-line formats precedence
set fileformat=unix " only for the initial unnamed buffer

" Command line completion mode
set wildmenu wildmode=longest:full,full
" Ignore case when completing file names and directories (Vim 7.3.072)
silent! set wildignorecase

" Dictionary files for insert-completion
let s:dictionaries = '~/.vim/spell/dictionary-oald.txt'
if filereadable(expand(s:dictionaries))
  let &dictionary = s:dictionaries
elseif !has('win32')
  set dictionary=/usr/share/dict/words
else
  set dictionary=spell " completion from spelling as an alternative
endif
set thesaurus=~/.vim/spell/thesaurus-mwcd.txt " thesaurus files for insert-completion

" Enable spell checking for particular file types
autocmd vimrc FileType gitcommit,markdown,txt setlocal spell
if v:version == 704 && has('patch088') || v:version > 704
  set spelllang+=cjk " skip spell check for East Asian characters
endif

set incsearch " show matches when typing the search pattern
set ignorecase " case insensitive in search patterns and command completion
set smartcase " case sensitive only when up case characters present

set autoindent " indent at the same level of the previous line
set shiftwidth=4 " number of spaces to use for each step of (auto)indent
set shiftround " use multiple of shiftwidth to round when indenting with '<' and '>'
set tabstop=4 " number of spaces a tab displayed in
set softtabstop=4 " number of spaces used when press <Tab> or <BS>
set expandtab " expand a tab to spaces
set smarttab " a <Tab> in front of a line inserts blanks according to 'shiftwidth'

set winminheight=0 " the minimal height of a window
set scrolloff=1 " minimum lines to keep above and below cursor
set sidescrolloff=5 " the minimal number of screen columns to keep around the cursor

set path=.,,~ " directories to search by 'gf', ':find', etc.
set cdpath=.,,~/workspaces " directories to search by ':cd', ':lcd'

set mouse=a " enable mouse in all modes
" set clipboard=unnamed " link unnamed register and OS clipboard:

set matchpairs+=<:> " character pairs used by '%'
runtime macros/matchit.vim " extended pair matching with '%'

set history=50 " a larger number of commands and search patterns to remember
set tabpagemax=50 " allow more tabs

autocmd GUIEnter * set vb t_vb= " disable error beep and screen flash
set nowritebackup " write to symbolic files safely on windows
set confirm " prompt for an action instead of fail immediately
set backspace=indent,eol,start " backspace through anything in insert mode
silent! set formatoptions+=j " remove comment characters when joining commented lines
set nrformats-=octal " exclude octal numbers when using C-A or C-X
set nolazyredraw " don't redraw the screen while executing macros etc.
set cryptmethod=blowfish " acceptable encryption strength, remember :set viminfo=
set shortmess=aoOtTI " avoid all the hit-enter prompts caused by file messages
set display+=lastline " ensure the last line is properly displayed

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
autocmd vimrc BufNewFile,BufReadPost _ set buftype=nofile bufhidden=hide

" ---------------------------------------------------------------------
" Mappings {{{1
" See :h index, :h map-which-keys
" Always use low case letter for mappings containing the Alt key. Because <A-K>
" is not the same as <A-k> for terminal Vim.

if !has('gui_running')
  " Make the Meta(Alt) key mappable in terminal. But some characters(h,j,k,l...)
  " often typed after pressing <Esc> are not touched, so not mappable.
  for c in split('qwertyasdfgzxcvbm', '\zs')
    execute "set <M-".c.">=\e".c
  endfor
endif

" Map ';' to ':' to reduce keystrokes
" NXnoremap ; :
" Don't use 'q;' as 'q' is often mapped to quit a window
NXnoremap z; q:
NXnoremap @; @:

" The substitution to ';' and ','
" NXnoremap - ;
" NXnoremap _ ,

" The counterpart to <CR>
" NXnoremap <S-CR> -

" Delete without affecting registers
NXnoremap R "_d

" See the buffer list
NXnoremap <Leader>ls :<C-U>ls<CR>

" Go to the next/previous tab page
noremap <C-l> gt
noremap <C-h> gT
noremap gl gt
noremap gh gT
" Go to a specific tab page
for n in range(1, 9)
  execute 'noremap ' . '<A-' . n . '> ' . n . 'gt'
endfor
" Move tabs
noremap gH :tabm -1<cr>
noremap gL :tabm +1<cr>

" Go to the next/previous window
noremap <C-j> <C-W>w
noremap <C-k> <C-W>W
noremap gj <C-W>w
noremap gk <C-W>W
" Split window vertically and edit the alternate file
noremap <c-w><c-^> :vsplit #<cr>

" Be consistent with other operators
nnoremap Y y$

" Make repeating last substitution keep the flags
NXnoremap & :&&<cr>

" Wrapped lines goes down/up to next row, rather than next line in file.
NXnoremap j gj
NXnoremap k gk

" Allow the `.` to execute once for each line of a visual selection.
xnoremap . :normal .<CR>

" Visual shifting (does not exit Visual mode)
xnoremap < <gv
xnoremap > >gv

" Easier horizontal scrolling
noremap zl zL
noremap zh zH

" Mappings for the cmdline window
autocmd vimrc CmdwinEnter * noremap <buffer> <F5> <CR>q:|
      \ NXInoremap <buffer> <C-C> <C-C><C-C>

" Mappings/options for a quickfix/location window
autocmd vimrc FileType qf nnoremap <buffer> q <C-W>c|
      \ nnoremap <buffer> <C-V> <C-W><CR><C-W>H|
      \ nnoremap <buffer> <C-T> <C-W><CR><C-W>T

" Edit a file in the same directory of the current file
NXnoremap <leader>ee :e <C-R>=expand('%:h')<CR>/
NXnoremap <leader>es :sp <C-R>=expand('%:h')<CR>/
NXnoremap <leader>ev :vs <C-R>=expand('%:h')<CR>/
NXnoremap <leader>et :tabe <C-R>=expand('%:h')<CR>/

" Source the current line of Vim scripts
nnoremap <silent> <leader>S mz^"zy$:@z<CR>`z
" Source a visual selection (continued lines joined)
xnoremap <silent> <leader>S mz:<C-U>silent '<,'>y z<Bar>let @z = substitute(@z, '\n\s*\\', '', 'g')<Bar>@z<CR>`z

" Quit diff mode and close other diff buffers
noremap <leader>do :diffoff \| windo if &diff \| hide \| endif<cr>

" Appends the current date or time after the cursor
nnoremap <leader>at a<C-R>=strftime("%a %b %d %H:%M:%S %Y")<CR><Esc>

" Reverse the selected text
xnoremap <leader>rv c<C-O>:set revins<CR><C-R>"<Esc>:set norevins<CR>

" Search words under the cursor via the Web
nnoremap gG :call netrw#NetrwBrowseX("http://www.google.com.hk/search?q=".expand("<cword>"),0)<cr>
nnoremap gW :call netrw#NetrwBrowseX("http://en.wikipedia.org/wiki/Special:Search?search=".expand("<cword>"),0)<cr>

" ---------------------------------------------------------------------
" Mappings! {{{1
" Open the command-line window
set cedit=<C-G>

" Don't move the cursor when pressing `i` and `<Esc>`
" inoremap <Esc> <Esc>`^

" Completion by words in dictionaries
inoremap <c-x>k <c-x><c-k>

" Break the undo sequence
inoremap <C-U> <C-G>u<C-U>

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
noremap! <expr> <SID>transposition getcmdpos()>strlen(getcmdline())?"\<Left>":getcmdpos()>1?'':"\<Right>"
noremap! <expr> <SID>transpose "\<BS>\<Right>".matchstr(getcmdline()[0 : getcmdpos()-2], '.$')
cmap <script> <C-T> <SID>transposition<SID>transpose

" ---------------------------------------------------------------------
" Commands {{{1
" Calculate the time spending on executing commands
command! -nargs=1 -complete=command Time call vimrc#time(<q-args>)

" Join lines with characters in between
command! -range -nargs=? Join <line1>,<line2>-1s/\s*\n\s*/<args>/

" Remove trailing white spaces
command! Trim %s/\s\+$//

" Substitute in a visual area
command! -range -nargs=1 SV s/\%V<args>

" Remove duplicate, consecutive lines
command! UniqConsecutive g/\v^(.*)\n\1$/d
" command! UniqConsecutive sort /\M$^/ u
" Remove duplicate, nonconsecutive and nonempty lines
command! UniqNonconsecutiveNonempty g/^./if search('^\V'.escape(getline('.'),'\').'\$', 'bW') | delete | endif <NL> silent! normal! ``
" This one is far slower than the above
" command! UniqNonconsecutiveNonempty g/\v^(.+)$\_.{-}^\1$/d <NL> silent! normal! ``

" Source a range of lines
command! -bar -range Source <line1>,<line2>y z<Bar>let @z = substitute(@z, '\n\s*\\', '', 'g')<Bar>@z<CR>

" Wipe out all unlisted buffers
command! BwUnlisted call vimrc#bufffer_wipe_unlisted()

" Create a path
command! -nargs=? -complete=dir Mkdir call vimrc#mkdir(<q-args>)

" Execute an external command silently
command! -nargs=1 -complete=shellcmd Silent call system(<q-args>)

" Diff with another file
command! -nargs=? -complete=buffer DiffWith call vimrc#diffwith(<f-args>)

" Clear undo history (:w to clear the undo file if presented)
command! -bar UndoClear execute "set ul=-1 | m-1 | let &ul=" . &ul

" Append a mode line
command! AppendModeline call vimrc#appendModeline()

" Simple letter encoding with rot13
command! Rot13 execute "normal ggg?G''"

" Search via Google
command! -nargs=1 Google call netrw#NetrwBrowseX("http://www.google.com.hk/search?q=".expand("<args>"),0)

" Grep using 'ag' or 'ack' without affecting 'grepprg' and 'grepformat'
command! -bar -nargs=+ -complete=file Ag call grep#grep('ag', <q-args>)
command! -bar -nargs=+ -complete=file Ack call grep#grep('ack', <q-args>)
command! -nargs=+ -complete=command Help call grep#help(<q-args>)
command! -nargs=+ -complete=command Helpgrep call grep#help('grep '.<q-args>)

" Calculate words frequency
command! -range=% WordFrequency <line1>,<line2>call vimrc#word_frequency()
" Count anything in a range of lines
command! -range=% -nargs=? Count echo vimrc#count(<q-args>, <line1>, <line2>) | normal ``
" Calculate the total lines of source code minus blank lines and comment lines.
command! -range=% SLOC echo vimrc#count('^[^' . &cms[0] . ']', <line1>, <line2>) | normal ``

" ---------------------------------------------------------------------
" Abbreviations {{{1
" Open help in a vertical window or a new tab
cabbrev vh vert h
cabbrev th tab h

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
" Appearance {{{1
" set number " print the line number in front of each line
set relativenumber " show the line number relative to the current line
set numberwidth=3 " minimal number(2) of columns to use for the line number

" set nowrap " only part of long lines will be displayed
set linebreak " don't break a word when displaying wrapped lines
" set showbreak=>\  " string to put at the start of wrapped lines

set list " show non-normal spaces, tabs etc.
if !has('win32') && (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8')
  let &listchars = "precedes:\u21c7,extends:\u21c9,tab:\u21e5 ,trail:\u2423,nbsp:\u00b7"
else
  set listchars=precedes:<,extends:>,tab:>\ ,trail:-,nbsp:+
endif

set showcmd " show partial commands in status line
" set showmatch " show matching brackets/braces (redundant with matchparen.vim)
set colorcolumn=+1 " highlight column after 'textwidth'

" A concise status line named "Starline"
set laststatus=2 " always display the status line
function! s:statusline()
  set statusline=%m%<%.60f " modified flag, file name(truncated if too long)
  set statusline+=\ %H%W%q%R%Y " help, preview, quickfix, read-only flag, file type
  set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?','.&fenc:''} " file encoding
  set statusline+=%{&ff!='unix'?','.&ff:''} " file format
  " Git branch status
  let &statusline .= exists('*fugitive#head') ?
        \ "%{exists('b:git_dir')?','.fugitive#head(7):''}" : ''
  " Software caps lock status
  let &statusline .= exists('*CapsLockSTATUSLINE') ? "%{CapsLockSTATUSLINE()}" : ''
  set statusline+=%= " left/right separator
  set statusline+=%{matchstr(getcwd(),'.*[\\/]\\zs\\S*')} " the working directory
  set statusline+=\ %c,%l/%L\ %P " cursor position, line percentage
endfunction
" Ensure all plugins are loaded before setting 'statusline'
execute (exists('g:loaded_vimrc') ? '' : 'autocmd VimEnter * ') . 'call s:statusline()'

" The status line for the quickfix window
autocmd vimrc FileType qf setlocal statusline=%t
      \%{strpart('\ '.get(w:,'quickfix_title',''),0,66)}%=\ %11.(%c,%l/%L\ %P%)

" Use CTRL-G, G_CTRL-G to see file and cursor information manually
set ruler " not effective when 'statusline' is set
set rulerformat=%50(%=%m%r%<%f%Y\ %l,%c\ %p%%%)

" set tabline=
" set titlestring=

if !exists('g:loaded_vimrc')
  if has('gui_running')
    if has('win32')
      set guifont=Consolas:h10
      autocmd GUIEnter * simalt ~x " max window
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
  if l
    if has('gui_running')
      color base16-solarized
    elseif has('unix')
      color terminator " twilight256
    endif
  else
    if has('gui_running') || &t_Co == 256
      color solarized
    else
      color terminator
    endif
  endif
endif

" if has('multi_byte_ime')
"   highlight CursorIM guifg=NONE guibg=#007500
" endif

let g:loaded_vimrc = 1
" ---------------------------------------------------------------------
" vim:ft=vim tw=80 et sw=2 fdm=marker cms="\ %s nowrap:
