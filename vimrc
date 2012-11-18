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
        let directory = '$HOME/.vim' . '/' . '.' . dirname . "/"
        let directory = substitute(directory, " ", "\\\\ ", "g")
        exec "set " . settingname . "=" . directory
    endfor
endfunction
call InitializeDirectories()
set viminfo+=n$HOME\\.vim\\.viminfo " change viminfo file dir

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
" }}}

" Setup bundles {{{1
    " Deps {{{2
        Bundle 'MarcWeber/vim-addon-mw-utils'
        Bundle 'tomtom/tlib_vim'
    "}}}

    " list only the plugin groups you will use
    let g:bundle_groups=['general', 'neocomplcache', 'programming', 'python', 'javascript', 'html', 'misc']

    " General {{{2
        if count(g:bundle_groups, 'general')
            Bundle 'scrooloose/nerdtree'
                map <C-n> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
                let NERDTreeShowBookmarks=1
                let NERDTreeIgnore=['\.pyc', '\~$', '\.swo$', '\.swp$', '\.git', '\.hg', '\.svn', '\.bzr']
                let NERDTreeChDirMode=0
                let NERDTreeQuitOnOpen=1
                let NERDTreeMouseMode=2
                let NERDTreeShowHidden=1
                let NERDTreeKeepTreeInNewTab=1
                let g:nerdtree_tabs_open_on_gui_startup=0
            Bundle 'jistr/vim-nerdtree-tabs'
                map <leader>n <plug>NERDTreeTabsToggle<CR>
            Bundle 'Lokaltog/vim-easymotion'

            Bundle 'tpope/vim-surround'
            Bundle 'tpope/vim-abolish'
            Bundle 'tpope/vim-unimpaired'
            Bundle 'tpope/vim-commentary'
            Bundle 'tpope/vim-speeddating'
            Bundle 'tpope/vim-repeat'
                "Adding support to a plugin is generally as simple as the following command at the end of your map functions.
                "silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)

            Bundle 'sjl/gundo.vim'
                nnoremap <F5> :GundoToggle<CR>
            Bundle 'jeetsukumaran/vim-buffergator'
            "Bundle 'corntrace/bufexplorer'
            Bundle 'myusuf3/numbers.vim'
            Bundle 'Raimondi/delimitMate'
            Bundle 'matchit.zip'
            Bundle 'kien/ctrlp.vim'
                let g:ctrlp_working_path_mode = 2
                nnoremap <silent> <D-t> :CtrlP<CR>
                nnoremap <silent> <D-r> :CtrlPMRU<CR>
                let g:ctrlp_custom_ignore = {
                    \ 'dir':  '\.git$\|\.hg$\|\.svn$',
                    \ 'file': '\.exe$\|\.so$\|\.dll$' }
            Bundle 'vim-scripts/sessionman.vim'
                set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
                nmap <leader>sl :SessionList<CR>
                nmap <leader>ss :SessionSave<CR>
            "Bundle 'restore_view.vim'
            Bundle 'nathanaelkane/vim-indent-guides'
                let g:indent_guides_start_level = 2
                let g:indent_guides_guide_size = 1
                let g:indent_guides_enable_on_vim_startup = 1
            Bundle 'vimwiki'
            Bundle 'altercation/vim-colors-solarized'
            Bundle 'spf13/vim-colors'
            "Bundle 'Lokaltog/vim-powerline'
            "Bundle 'flazz/vim-colorschemes'
            "Bundle 'godlygeek/csapprox'
        endif

    " General Programming {{{2
        if count(g:bundle_groups, 'programming')
            " Pick one of the checksyntax, jslint, or syntastic
            Bundle 'scrooloose/syntastic'
            Bundle 'tpope/vim-fugitive'
                nnoremap <silent> <leader>gs :Gstatus<CR>
                nnoremap <silent> <leader>gd :Gdiff<CR>
                nnoremap <silent> <leader>gc :Gcommit<CR>
                nnoremap <silent> <leader>gb :Gblame<CR>
                nnoremap <silent> <leader>gl :Glog<CR>
                nnoremap <silent> <leader>gp :Git push<CR>
            "Bundle 'scrooloose/nerdcommenter'
            Bundle 'godlygeek/tabular'
            Bundle 'mattn/webapi-vim'
            Bundle 'mattn/gist-vim'
            if executable('ctags')
                Bundle 'majutsushi/tagbar'
                nnoremap <silent> <leader>tt :TagbarToggle<CR>
            endif
        endif

    " Snippets & neocomplcache {{{2
        if count(g:bundle_groups, 'snipmate')
            Bundle 'garbas/vim-snipmate'
            Bundle 'honza/snipmate-snippets'
            " Source support_function.vim to support snipmate-snippets.
            if filereadable(expand("~/.vim/bundle/snipmate-snippets/snippets/support_functions.vim"))
                source ~/.vim/bundle/snipmate-snippets/snippets/support_functions.vim
            endif
        elseif count(g:bundle_groups, 'neocomplcache')
            Bundle 'Shougo/neocomplcache'
            Bundle 'Shougo/neosnippet'
            Bundle 'honza/snipmate-snippets'
        endif

    " PHP {{{2
        if count(g:bundle_groups, 'php')
            Bundle 'spf13/PIV'
            Bundle 'beyondwords/vim-twig'
        endif

    " Java {{{2
        if count(g:bundle_groups, 'scala')
            Bundle 'derekwyatt/vim-scala'
            Bundle 'derekwyatt/vim-sbt'
        endif

    " Python {{{2
        if count(g:bundle_groups, 'python')
            " Pick either python-mode or pyflakes & pydoc
            Bundle 'klen/python-mode'
                if !has('python')
                   let g:pymode = 1
                endif
                let g:pymode_lint_checker = "pyflakes"
            Bundle 'python.vim'
            Bundle 'python_match.vim'
            Bundle 'pythoncomplete'
        endif

    " Ruby {{{2
        if count(g:bundle_groups, 'ruby')
            "Bundle 'tpope/vim-rails'
            "Bundle 'tpope/vim-cucumber'
            "Bundle 'quentindecock/vim-cucumber-align-pipes'
            let g:rubycomplete_buffer_loading = 1
            "let g:rubycomplete_classes_in_global = 1
            "let g:rubycomplete_rails = 1
        endif

    " Javascript {{{2
        if count(g:bundle_groups, 'javascript')
            Bundle 'leshill/vim-json'
            Bundle 'groenewege/vim-less'
            Bundle 'pangloss/vim-javascript'
            Bundle 'briancollins/vim-jst'
        endif

    " HTML {{{2
        if count(g:bundle_groups, 'html')
            Bundle 'amirh/HTML-AutoCloseTag'
            Bundle 'hail2u/vim-css3-syntax'
        endif

    " Misc {{{2
        if count(g:bundle_groups, 'misc')
            Bundle 'tpope/vim-markdown'
            Bundle 'spf13/vim-preview'
            Bundle 'Puppet-Syntax-Highlighting'
        endif
    " }}}
" }}}

" Behaviour(Affect Interaction){{{1
cd ~ " change initial dir
filetype plugin indent on   " Automatically detect file types, must be after pathogen or vundle setup
set path+=~,~/configent/**
" Encrypt options {{{2
" Acceptable encryption strength, also remember to set viminfo=,
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
" formatting {{{2
    set nowrap                      " no wrap long lines
    set autoindent                  " indent at the same level of the previous line
    set shiftwidth=4                " use indents of 4 spaces
    set expandtab                   " tabs are spaces, not tabs
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
    inoremap jk <Esc>
    cmap w!! w !sudo tee % >/dev/null
    " Source current line
    nnoremap <leader>S ^y$:@"<cr>
    " Space to toggle folds.
    nnoremap <space> za
    vnoremap <space> za
    " Toggle paste mode
    nmap <silent> <F4> :set invpaste<CR>:set paste?<CR>
    imap <silent> <F4> <ESC>:set invpaste<CR>:set paste?<CR>
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
    " set text wrapping toggles
    nmap <silent> <leader>tw :set invwrap<CR>:set wrap?<CR>
    " Underline the current line with '=', frequently used in markdown headings
    "nmap <silent> <leader>ul :t.\|s/./=/g\|:nohls<cr>
    " find merge conflict markers, maybe duplicate as unimpaired exists mappings [n ]n
    "nmap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>
    " Toggle hlsearch with <leader>hs
    nmap <leader>hs :set hlsearch! hlsearch?<CR>
    " Adjust viewports to the same size
    map <Leader>= <C-w>=
    " cd to the directory containing the file in the buffer
    nmap <silent> <leader>cd :lcd %:h<CR>
    cmap cd. lcd %:p:h
    " Create the directory containing the file in the buffer
    nmap <silent> <leader>md :!mkdir -p %:p:h<CR>
    " Easier moving in tabs and windows
    map <C-J> <C-W>j<C-W>_
    map <C-K> <C-W>k<C-W>_
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
    nnoremap / /\v
    vnoremap / /\v
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
set statusline=%<%f\    " Filename
set statusline+=%w%h%m%r " Options
set statusline+=%{fugitive#statusline()} "  Git Hotness
set statusline+=\ [%{&ff}/%Y]            " filetype
set statusline+=\ [%{getcwd()}]          " current dir
set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
" }}}
" }}}

" Functions{{{1
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
