" Environment {{{1
set nocompatible        " must be first line
" automatically source vimrc
"au BufWritePost vimrc so ~/.vimrc
" shortcut to edit this vimrc file in a new tab
command! Vimrc :tabe ~/vimise/vimrc

" Windows Environment {{{2
if has('win32') || has('win64')
  " set runtimepath to Unix default
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
  " work with powershell
  "set shell=powershell
  "set shellcmdflag=-command
endif

" Setup pathogen and disable bundles {{{2
runtime bundle/vim-pathogen/autoload/pathogen.vim

" Disable bundles
" Rename a bundle like "rails" to "rails~" to disable this bundle
" Or add disabled bundles to this list
let g:pathogen_disabled = []
if has('gui_running')
    call add(g:pathogen_disabled, 'csapprox')
endif

call pathogen#infect()

" Load plugins that ship with Vim {{{2
runtime macros/matchit.vim
" setup custome vim directories {{{2
" all temporary info come to ~/.vim/tmp
function! InitializeDirectories()
    let separator = "."
    let parent = $HOME
    let prefix = '/.vim/tmp/'
    let dir_list = { 'backup': 'backupdir', 'views': 'viewdir', 'undo': 'undodir', 'swap': 'directory' }
    for [dirname, settingname] in items(dir_list)
        let directory = parent . prefix . dirname . "/"
        if exists("*mkdir")
            if !isdirectory(directory)
                call mkdir(directory)
            endif
        endif
        if !isdirectory(directory)
            echo "Warning: Unable to create backup directory: " . directory
            echo "Try: mkdir -p " . directory
        else
            let directory = substitute(directory, " ", "\\\\ ", "g")
            exec "set " . settingname . "=" . directory
        endif
    endfor
endfunction
call InitializeDirectories()
set viminfo='50,<50,s10,h,n$HOME/.vim/tmp/viminfo " keep less info and change viminfo file dir

" improving security and efficiency while losing recovery and convenience {{{2
" set noswapfile
" set viminfo=
" makes Vim write the buffer to the original file (resulting in the risk of destroying it in case of an I/O error)
" but there will be no problem when you write to symbolic files on windows
set nowritebackup " write to the original file
" set undofile                "so is persistent undo ...
" set undolevels=1000         "maximum number of changes that can be undone
" set undoreload=10000        "maximum number lines to save for undo on a buffer reload
" fileformats and encodings {{{2
set fileformats=unix,dos " will set new file to unix format
set fileformat=unix " local to buffer, this option is set automatically when starting to edit a file
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,latin1
set encoding=utf-8 "Sets the character encoding used inside Vim, conversion will be done when 'encoding' and 'fileencoding' is defferent
" }}}
let mapleader = "," " put ahead to make following maps work
" }}}1

" Source a common vimrc file(vicrc) shared by other vimrcs {{{1
    source ~/vimise/vicrc
" }}}

" Source the bundle configuration file {{{1
    "source ~/vimise/vimrc.bundle
" }}}

" Behaviour(Affect Interaction){{{1
" unclassified {{{2
filetype plugin indent on   " Automatically detect file types, must be after pathogen or vundle setup
set path+=~,~/configent/**
set autoread " Automatically read a file that has changed(not delete) on disk
if 0 == argc() " if no files to edit at startup, change working directory to HOME
    cd $HOME
endif
set clipboard=unnamed " Link unnamed register and OS clipboard:
" enable vim scripts syntax based foldding. refer: http://vim.wikia.com/wiki/Syntax_folding_of_Vim_scripts
let g:vimsyn_folding='af'
set viewoptions=folds,options,cursor,unix,slash " 'slash' and 'unix' are useful on Windows when sharing view files
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
"set timeoutlen=500 " mapping delay, default is 1000ms
set ttimeoutlen=50 " key code delay, same as timeoutlen when < 0(default)
au GUIEnter * set vb t_vb= " disable error sounds and error screen flash
syntax on                   " syntax highlighting
set hidden                      " allow buffer switching without saving
set mouse=a                 " automatically enable mouse usage
set history=1000                " Store a ton of history (default is 20)
set shortmess+=filmnrwxoOtTI      " abbrev. of messages and avoids 'hit enter'
set showcmd                 " show partial commands in status line and
set visualbell t_vb= " no beep or flash
set nrformats=alpha "also increse alpha characters use <c-a>/<c-x>
set scrolljump=5                " lines to scroll when cursor leaves screen
set scrolloff=3                 " minimum lines to keep above and below cursor
"set foldenable                  " fold code, use zi to toggle
set wildmenu                    " show list instead of just completing
set wildmode=list:longest,full  " command <Tab> completion, list matches, then longest common part, then all.
set backspace=indent,eol,start  " backspace for dummies
set nolazyredraw " Don't redraw while executing macros
"set nojoinspaces " no auto append spaces when joinin lines
set spell                       " spell checking on
"}}}
" OmniComplete {{{2
    if has("autocmd") && exists("+omnifunc")
        autocmd Filetype *
            \if &omnifunc == "" |
            \setlocal omnifunc=syntaxcomplete#Complete |
            \endif
    endif

    hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
    hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
    hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

    " some convenient mappings
    inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
    inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
    inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
    inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
    inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

    " automatically open and close the popup menu / preview window
    au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
    set completeopt=menu,preview,longest
" }}}2
" Encrypt options {{{2
" Acceptable encryption strength, also remember to set viminfo=
" swap and undo are all encrypted, but may set nowritebackup and nobackup(default)
set cryptmethod=blowfish "}}}
" search {{{2
set incsearch                   " find as you type search
set ignorecase                  " case insensitive search
set smartcase                   " case sensitive when uc present
"set hlsearch                    " highlight search terms
set whichwrap+=<,>,[,]          " allow left and right arrow keys to move beyond current line
" formatting {{{2
    set nowrap                      " no wrap long lines
    set autoindent                  " indent at the same level of the previous line
    set textwidth=80                " auto insert newline when textwidth is too long
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

" Mappings, commands and abbreviations {{{1
" when define mappings, check out ":h index", which contains a list of all
" commands for each mode, with a tag and a short description.
    nnoremap ; :
    xnoremap ; :
    nnoremap q; q:
    nnoremap @; @:
    nnoremap \ ;
    inoremap jk <Esc>
    cnoremap jk <Esc>
    nnoremap Y y$
    " Easily moving in tabs and windows
    noremap <C-J> <C-W>w
    noremap <C-K> <C-W>W
    noremap <C-L> <C-W>l
    noremap <C-H> <C-W>h
    " toggle fold
    nnoremap <space> za
    vnoremap <space> za
    " two fingers tab navigation
    nnoremap gj gt
    nnoremap gk gT
    " familiar command line editing shortcuts
    cnoremap <C-a> <Home>
    cnoremap <C-e> <End>
    cmap w!! w !sudo tee % >/dev/null
    " cd to the directory containing the current buffer
    cmap lcd. lcd %:p:h
    cmap cd. cd %:p:h
    " vertical split buffer
    cnoremap vsb vert sb 
    " Toggle paste mode
    nnoremap <silent> <F4> :set invpaste<CR>:set paste?<CR>
    imap <silent> <F4> <ESC>:set invpaste<CR>:set paste?<CR>
    " Toggle hlsearch
    nnoremap <leader>/ :set hlsearch! hlsearch?<CR>
    " set text wrapping toggles
    nnoremap <silent> <leader>tw :set invwrap<CR>:set wrap?<CR>
    " set spell toggles
    nnoremap <silent> <leader>ts :set invspell<CR>:set spell?<CR>
    " Wrapped lines goes down/up to next row, rather than next line in file.
    nnoremap j gj
    nnoremap k gk
    " display help window at bottom right
    command! -nargs=1 -complete=help H :wincmd b | :bel h 
    " visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv
    " Some helpers to edit mode, see: http://vimcasts.org/e/14
    cnoremap %% <C-R>=expand('%:h').'/'<cr>
    nmap <leader>ew :e %%
    nmap <leader>es :sp %%
    nmap <leader>ev :vsp %%
    nmap <leader>et :tabe %%
    " Easier horizontal scrolling
    noremap zl zL
    noremap zh zH
    " Source current line
    nnoremap <leader>S ^y$:@"<cr> :echo "current line sourced."<cr>
    " Source visual selection
    vnoremap <leader>S y:@"<cr> :echo "selected lines sourced."<cr>
    " upper/lower word
    nnoremap <leader>u mQviwU`Q
    nnoremap <leader>l mQviwu`Q
    " upper/lower first char of word
    nnoremap <leader>U mQgewvU`Q
    nnoremap <leader>L mQgewvu`Q
    " Swap two words
    nnoremap <silent> gw :s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR>`'
    " Create a directory based the current buffer's path
    command! -nargs=? -complete=dir Mkdir :call mkdir(expand('%:p:h') . "/" . <q-args>, "p")
    " Underline the current line with '=', frequently used in markdown headings
    nnoremap <silent> <leader>ul :t.\|s/./=/g\|:nohls<cr>
    " find merge conflict markers, maybe duplicate as unimpaired exists mappings [n ]n
    "nnoremap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>
    " set a fold level quickly "{{{3
    nnoremap <leader>f0 :set foldlevel=0<CR>
    nnoremap <leader>f1 :set foldlevel=1<CR>
    nnoremap <leader>f2 :set foldlevel=2<CR>
    nnoremap <leader>f3 :set foldlevel=3<CR>
    nnoremap <leader>f4 :set foldlevel=4<CR>
    nnoremap <leader>f5 :set foldlevel=5<CR>
    nnoremap <leader>f6 :set foldlevel=6<CR>
    nnoremap <leader>f7 :set foldlevel=7<CR>
    nnoremap <leader>f8 :set foldlevel=8<CR>
    nnoremap <leader>f9 :set foldlevel=9<CR> "}}}3
    " execute current ruby file (make ruby)
    command! Mr :let f=expand("%")|wincmd w|
                 \ if bufexists("mr_output")|e! mr_output|else|sp mr_output|endif |
                 \ execute '$!ruby "' . f . '"'|wincmd W
    " personal plugin related {{{2
        nnoremap <leader>sl :SessionList<CR>
        nnoremap <leader>ss :SessionSave<CR>
        nnoremap <leader>sa :SessionSaveAs<CR>
    " }}}2
    " Abbreviations {{{2
    " quickly call functions instead of define many maps or commands
    ca c call
    }}}2
" }}}

" Appearance(Vim UI, Statistic Elements){{{1
set background=dark         " Assume a dark background for colorschemes
set showmode                    " display the current mode
set cursorline                  " highlight current line
set ruler                   " show the ruler
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " a ruler on steroids
if &term == 'xterm' || &term == 'xterm-256color' || &term == 'screen'
    set t_Co=256 " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
    let g:solarized_termcolors=256
endif
if has('gui_running')
    color solarized
elseif has('unix')
    color molokai
else
    color molokai
endif
set number                          " Line numbers on
set relativenumber " relative number
set showmatch                   " show matching brackets/parenthesis
set winminheight=0              " windows can be 0 line high
" show non-normal spaces, tabs etc. But conflict with 'linkbreak' which is used for wrap at word boundry
"set list
set linebreak
set listchars=tab:,.,trail:.,extends:>,precedes:<,nbsp:% "(eol:¬), Highlight problematic whitespace
" statusline {{{2
set laststatus=2
" if want colorful, '%1' is switch to User1 highlight and '%*' is switch back to statusline highlight
" like 'set statusline=%1*%f%*'
set statusline=%<%f\ %m%r%w%h " cut at start, path and status, 
" set statusline+=\ %{strftime(\"%X\",getftime(expand(\"%:p\")))} " file modified time
set statusline+=\ %{fugitive#statusline()} "  Git Hotness
set statusline+=\ [%{&ff}/%{strlen(&fenc)?&fenc:'none'}/%Y] " fileformat, fileencoding and filetype
" set statusline+=\ [%{getcwd()}]          " current dir
set statusline+=%=      "left/right separator
set statusline+=%-11.(%v\ %l/%L%)\ %p%%  " right offset position info and show percentage
" must after ':color xxx' statement
"in gui, fg is actually background light blue, and bg is actually font color
hi statusline ctermbg=Gray ctermfg=black guibg=black guifg=DarkCyan
" }}}
" }}}

" vim: nowrap fdm=marker
