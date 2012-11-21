" Environment {{{1
" vim: nowrap fdm=marker
set nocompatible        " must be first line
" automatically source vimrc
"au BufWritePost vimrc so ~/.vimrc
" On Windows, also use '.vim' instead of 'vimfiles' {{{2
if has('win32') || has('win64')
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif
" Setup vundle {{{2
    filetype off                   " required!
    set rtp+=~/.vim/bundle/vundle/
    call vundle#rc()
    Bundle 'gmarik/vundle'

" Load plugins that ship with Vim {{{2
runtime macros/matchit.vim
" setup custome vim directories {{{2
function! InitializeDirectories()
    let dir_list = { 'backup': 'backupdir', 'views': 'viewdir', 'undo': 'undodir', 'swap': 'directory' }
    for [dirname, settingname] in items(dir_list)
        let directory = '$HOME/.vim' . '/' . 'tmp/' . '.' . dirname . "/"
        let directory = substitute(directory, " ", "\\\\ ", "g")
        exec "set " . settingname . "=" . directory
    endfor
endfunction
call InitializeDirectories()
set viminfo+=n$HOME\\.vim\\tmp\\.viminfo " change viminfo file dir

" Disable swapfile and backup {{{2
" set nobackup
" set noswapfile
" fileformats and encodings {{{2
set fileformats=unix,dos
set fileformat=unix
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,latin1
set encoding=utf-8
" }}}
let mapleader = "," " put ahead to make following maps work
" 

" Source bundles {{{1
    source ~/vimise/vimrc.bundle
" }}}

" Behaviour(Affect Interaction){{{1
cd ~ " change initial dir
filetype plugin indent on   " Automatically detect file types, must be after pathogen or vundle setup
set path+=~,~/configent/**
" set clipboard=unnamed " Link unnamed register and OS clipboard:
" Encrypt options {{{2
" Acceptable encryption strength, also remember to set viminfo=
" swap and undo are all encrypted, but may set nowritebackup and nobackup(default)
set cryptmethod=blowfish "}}}
set viewoptions=folds,options,cursor,unix,slash " better unix / windows compatibility
"set timeoutlen=500 " mapping delay, default is 1000ms
set ttimeoutlen=50 " key code delay, same as timeoutlen when < 0(default)
au GUIEnter * set vb t_vb= " disable error sounds and error screen flash
syntax on                   " syntax highlighting
set hidden                      " allow buffer switching without saving
set mouse=a                 " automatically enable mouse usage
set history=1000                " Store a ton of history (default is 20)
set shortmess+=filmnrxoOtT      " abbrev. of messages and avoids 'hit enter'
set showcmd                 " show partial commands in status line and
set visualbell t_vb= " no beep or flash
set nrformats=alpha "also increse alpha characters use <c-a>/<c-x>
set scrolljump=5                " lines to scroll when cursor leaves screen
set scrolloff=3                 " minimum lines to keep above and below cursor
"set foldenable                  " auto fold code, use zi to toggle
set wildmenu                    " show list instead of just completing
set wildmode=list:longest,full  " command <Tab> completion, list matches, then longest common part, then all.
set backspace=indent,eol,start  " backspace for dummies
set nolazyredraw " Don't redraw while executing macros
"set nojoinspaces " no auto append spaces when joinin lines
set spell                       " spell checking on
" search {{{2
set incsearch                   " find as you type search
set ignorecase                  " case insensitive search
set smartcase                   " case sensitive when uc present
set hlsearch                    " highlight search terms
set whichwrap+=<,>,[,]          " allow left and right arrow keys to move beyond current line
" formatting {{{2
    set nowrap                      " no wrap long lines
    set autoindent                  " indent at the same level of the previous line
    set shiftwidth=4                " use indents of 4 spaces
    set shiftround                  " use multiple of shiftwidth when indenting with '<' and '>'
    set expandtab                   " tabs are spaces, not tabs
    set smarttab      " insert tabs on the start of a line according to shiftwidth, not tabstop
    set tabstop=4                   " an indentation every four columns
    set softtabstop=4               " let backspace delete indent
    "set matchpairs+=<:>                " match, to be used with %
    set pastetoggle=<f12>           " pastetoggle (sane indentation on pastes)
    "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
    " remove trailing whitespaces and ^m chars
    autocmd filetype c,cpp,java,php,javascript,python,twig,xml,yml autocmd bufwritepre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))
    autocmd bufnewfile,bufread *.html.twig set filetype=html.twig
" }}}
" }}}

" Key Mappings {{{1
" when define mappings, check out :h index
" that file contains a list of all commands for each mode, with a tag and a
" short description.
    " frequently used mappings {{{2
    " I prefer not to move my fingers
    inoremap jk <Esc>
    cnoremap jk <Esc>
    " I use ":" much more than ";", but remember this map is just for quick accessing command line
    nnoremap ; :
    nnoremap q; q:
    " I do miss ";", but mapping ":" to ";" may affect other normal maps which don't use noremap
    " Maybe I will forget ";" to begin a new life.
    " nnoremap : ;
    cmap w!! w !sudo tee % >/dev/null
    " Source current line
    nnoremap <leader>S ^y$:@"<cr> :echo "current line sourced."<cr>
    " Source visual selection
    vnoremap <leader>S y:@"<cr> :echo "selected lines sourced."<cr>
    " Space to toggle folds.
    nnoremap <space> za
    vnoremap <space> za
    " two fingers tab navigation
    nnoremap gj gt
    nnoremap gk gT
    "}}}
    " vertical split buffer
    cnoremap vsb vert sb
    " Toggle paste mode
    nmap <silent> <F4> :set invpaste<CR>:set paste?<CR>
    imap <silent> <F4> <ESC>:set invpaste<CR>:set paste?<CR>
    " Toggle hlsearch
    nmap <leader>/ :set hlsearch! hlsearch?<CR>
    " set text wrapping toggles
    nmap <silent> <leader>tw :set invwrap<CR>:set wrap?<CR>
    " upper/lower word
    nmap <leader>u mQviwU`Q
    nmap <leader>l mQviwu`Q
    " upper/lower first char of word
    nmap <leader>U mQgewvU`Q
    nmap <leader>L mQgewvu`Q
    " Swap two words
    nmap <silent> gw :s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR>`'
    " Underline the current line with '='
    "nmap <silent> <leader>ul :t.\|s/./=/g\|:nohls<cr>
    " Underline the current line with '=', frequently used in markdown headings
    "nmap <silent> <leader>ul :t.\|s/./=/g\|:nohls<cr>
    " find merge conflict markers, maybe duplicate as unimpaired exists mappings [n ]n
    "nmap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>
    " Adjust viewports to the same size
    map <Leader>= <C-w>=
    " cd to the directory containing the file in the buffer
    nmap <silent> <leader>cd :lcd %:h<CR>
    cmap cd. lcd %:p:h
    " Create the directory containing the file in the buffer
    nmap <silent> <leader>md :!mkdir -p %:p:h<CR>
    " Easier moving in tabs and windows
    map <C-J> <C-W>j
    map <C-K> <C-W>k
    map <C-L> <C-W>l
    map <C-H> <C-W>h
    " Wrapped lines goes down/up to next row, rather than next line in file.
    nnoremap j gj
    nnoremap k gk
    " Yank from the cursor to the end of the line, to be consistent with C and D.
    nnoremap Y y$
    " visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv
    " Some helpers to edit mode
    " http://vimcasts.org/e/14
    cnoremap %% <C-R>=expand('%:h').'/'<cr>
    map <leader>ew :e %%
    map <leader>es :sp %%
    map <leader>ev :vsp %%
    map <leader>et :tabe %%
    " Easier horizontal scrolling
    map zl zL
    map zh zH
    cnoremap <C-a> <Home>
    cnoremap <C-e> <End>
    "very magic(egrep) instead of magic(grep)
    "nnoremap / /\v
    "vnoremap / /\v
    """ Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>
" }}}

" Appearance(Vim UI, Statistic Elements){{{1
set background=dark         " Assume a dark background for colorschemes
set showmode                    " display the current mode
set cursorline                  " highlight current line
set ruler                   " show the ruler
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " a ruler on steroids
if &term == 'xterm' || &term == 'screen'
    set t_Co=256 " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
    let g:solarized_termcolors=256
endif
set number                          " Line numbers on
set showmatch                   " show matching brackets/parenthesis
set winminheight=0              " windows can be 0 line high
set list "show non-normal spaces, tabs etc.
set listchars=tab:,.,trail:.,extends:>,precedes:<,nbsp:% "(eol:¬), Highlight problematic whitespace
" statusline {{{2
set laststatus=2
" Broken down into easily includeable segments
set statusline=%<%f\ %m%r%w%h " filename and status
" set statusline+=\ %{strftime(\"%X\",getftime(expand(\"%:p\")))} " file modified time
set statusline+=\ %{fugitive#statusline()} "  Git Hotness
set statusline+=\ [%{&ff}/%Y]            " fileformat and filetype
" set statusline+=\ [%{getcwd()}]          " current dir
set statusline+=\ %=%-4.(%v\ %l/%L%)\ %p%%  " Right aligned file nav info
hi statusline guifg=#086989 "actually is background light blue
hi statusline guibg=black "actually is font color
" }}}
" tabline {{{2
"http://vim.wikia.com/wiki/Show_tab_number_in_your_tab_line
function! MyTabLine()
  let s = '' " complete tabline goes here
  " loop through each tab page
  for t in range(tabpagenr('$'))
    " select the highlighting for the buffer names
    if t + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    " empty space
    let s .= ' '
    " set the tab page number (for mouse clicks)
    let s .= '%' . (t + 1) . 'T'
    " set page number string
    let s .= t + 1 . ' '
    " get buffer names and statuses
    let n = ''  "temp string for buffer names while we loop and check buftype
    let m = 0 " &modified counter
    let bc = len(tabpagebuflist(t + 1))  "counter to avoid last ' '
    " loop through each buffer in a tab
    for b in tabpagebuflist(t + 1)
      " buffer types: quickfix gets a [Q], help gets [H]{base fname}
      " others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
      if getbufvar( b, "&buftype" ) == 'help'
        let n .= '[H]' . fnamemodify( bufname(b), ':t:s/.txt$//' )
      elseif getbufvar( b, "&buftype" ) == 'quickfix'
        let n .= '[Q]'
      else
        let n .= pathshorten(bufname(b))
        "let n .= bufname(b)
      endif
      " check and ++ tab's &modified count
      if getbufvar( b, "&modified" )
        let m += 1
      endif
      " no final ' ' added...formatting looks better done later
      if bc > 1
        let n .= ' '
      endif
      let bc -= 1
    endfor
    " add modified label [n+] where n pages in tab are modified
    if m > 0
      "let s .= '[' . m . '+]'
      let s.= '+ '
    endif
    " add buffer names
    if n == ''
      let s .= '[No Name]'
    else
      let s .= n
    endif
    " switch to no underlining and add final space to buffer list
    "let s .= '%#TabLineSel#' . ' '
    let s .= ' '
  endfor
  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'
  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999XX'
  endif
  return s
endfunction
set tabline=%!MyTabLine()
" }}}
" }}}

" Functions{{{1
" diff current file with current saved file or a different buffer
function! DiffWith(...)
  let filetype=&ft
  tab sp " open current buffer in a new tab
  diffthis
  if a:0 == 0
    " load the original file
    vnew | r # | normal! 1Gdd
    " make it temp
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
  else
    exe "vert sb " . a:1
  endif
  diffthis
endfunction
com! -nargs=? -complete=buffer DiffWith call DiffWith(<f-args>)

function! RedirMessages(msgcmd, destcmd)
    " Redirect messages to a variable.
    redir => message
    " Execute the specified Ex command
    silent execute a:msgcmd
    redir END

    " If no command is provided, output will be placed in the current buffer.
    if strlen(a:destcmd) " destcmd is not an empty string
        silent execute a:destcmd
    endif

    " Place the messages in the destination buffer.
    silent put=message " a variable is also a expression
endfunction
" examples   :TabMessage echo "Key mappings for Control+A:" | map <C-A>
command! -nargs=+ -complete=command BufMessage call RedirMessages(<q-args>, ''       )
command! -nargs=+ -complete=command WinMessage call RedirMessages(<q-args>, 'new'    )
command! -nargs=+ -complete=command TabMessage call RedirMessages(<q-args>, 'tabnew' )

" Set directory-wise configuration.
" Search from the directory the file is located upwards to the root for
" a local configuration file called .lvimrc and sources it.
" The local configuration file is expected to have commands affecting
" only the current buffer.
function SetLocalOptions(fname)
	let dirname = fnamemodify(a:fname, ":p:h")
	while "/" != dirname
		let lvimrc  = dirname . "/.lvimrc"
		if filereadable(lvimrc)
			execute "source " . lvimrc
			break
		endif
		let dirname = fnamemodify(dirname, ":p:h:h")
	endwhile
endfunction
" au BufNewFile,BufRead * call SetLocalOptions(bufname("%"))

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d :",
        \ &tabstop, &shiftwidth, &textwidth)
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>
