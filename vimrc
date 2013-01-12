" Bohr's vimrc

" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

" Source a common vimrc file(vicrc)
source <sfile>:h/vimise/vicrc

" Section: pathogen {{{1
runtime bundle/vim-pathogen/autoload/pathogen.vim
" Rename a bundle like "rails" to "rails~" to disable it Or add disabled bundles to the list bellow.
let g:pathogen_disabled = []
if has('gui_running')
    call add(g:pathogen_disabled, 'csapprox')
endif
call pathogen#infect()
" }}}1

" Section: Options {{{1
filetype plugin indent on " Must be after pathogen or vundle setup
" Improve the ability of recovery
" set undofile                "set persistent undo
" }}}1

" Section: Mappings {{{1
    " find merge conflict markers, maybe duplicate as unimpaired exists mappings [n ]n
    "nnoremap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>
    " set a fold level quickly "{{{2
    nnoremap <leader>f0 :set foldlevel=0<CR>
    nnoremap <leader>f1 :set foldlevel=1<CR>
    nnoremap <leader>f2 :set foldlevel=2<CR>
    nnoremap <leader>f3 :set foldlevel=3<CR>
    nnoremap <leader>f4 :set foldlevel=4<CR>
    nnoremap <leader>f5 :set foldlevel=5<CR>
    nnoremap <leader>f6 :set foldlevel=6<CR>
    nnoremap <leader>f7 :set foldlevel=7<CR>
    nnoremap <leader>f8 :set foldlevel=8<CR>
    nnoremap <leader>f9 :set foldlevel=9<CR> "}}}2
    " personal plugin related {{{2
        nnoremap <leader>sl :SessionList<CR>
        nnoremap <leader>ss :SessionSave<CR>
        nnoremap <leader>sa :SessionSaveAs<CR>
    " }}}2
" }}}1

" Section: Commands {{{1
" shortcut to edit this vimrc file in a new tab
command! Vimrc :tabe ~/vimise/vimrc
" execute current ruby file (make ruby)
command! Mr :let f=expand("%")|wincmd w|
            \ if bufexists("mr_output")|e! mr_output|else|sp mr_output|endif |
            \ execute '$!ruby "' . f . '"'|wincmd W
" }}}1

" Section: Autocommands {{{1
" }}}1

" Section: Appearance {{{1
if has('gui_running')
    color solarized
elseif has('unix')
    color molokai
else
    color molokai
endif
set statusline+=\ %{fugitive#statusline()} "  Git Hotness
" }}}1

" Source the bundle configuration file
"source ~/vimise/vimrc.bundle

" Behaviour(Affect Interaction){{{1
set viewoptions=folds,options,cursor,unix,slash " 'slash' and 'unix' are useful on Windows when sharing view files
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
"set timeoutlen=500 " mapping delay, default is 1000ms
set ttimeoutlen=50 " key code delay, same as timeoutlen when < 0(default)
syntax on                   " syntax highlighting
set history=1000                " Store a ton of history (default is 20)
"set foldenable                  " fold code, use zi to toggle
set nolazyredraw " Don't redraw while executing macros
"set nojoinspaces " no auto append spaces when joinin lines
"set hlsearch                    " highlight search terms
set whichwrap+=<,>,[,]          " allow left and right arrow keys to move beyond current line
"set matchpairs+=<:>                " match, to be used with %
"set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
" remove trailing whitespaces and ^m chars
autocmd filetype c,cpp,java,php,javascript,python,twig,xml,yml autocmd bufwritepre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))
autocmd bufnewfile,bufread *.html.twig set filetype=html.twig
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
" }}}


" vim:set ft=vim et tw=78 sw=2 fdm=marker nowrap:
