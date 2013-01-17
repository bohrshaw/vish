" Bohr's vimrc

" A unified runtime path(Unix default)
set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

" Source a common vimrc file(vimrc.core)
source <sfile>:h/vimise/vimrc.core
"runtime! macros/matchit.vim

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
set history=1000                " Store a ton of history (default is 20)
set whichwrap+=<,>,[,]          " allow left and right arrow keys to move beyond current line
set nolazyredraw " Don't redraw while executing macros
" set undofile                "set persistent undo
"set foldenable                  " fold code, use zi to toggle
"set nojoinspaces " no auto append spaces when joinin lines
"set hlsearch                    " highlight search terms
"set matchpairs+=<:>                " match, to be used with %
"set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
" Personal plugin options"{{{2
"}}}2

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
        nnoremap <leader>sl :SSlist<CR>
        nnoremap <leader>ss :SSsave<CR>
        nnoremap <leader>sa :SSsaveas<CR>
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

" remove trailing whitespaces and ^m chars
autocmd filetype c,cpp,java,php,javascript,python,twig,xml,yml autocmd bufwritepre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))

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
source ~/vimise/vimrc.bundle

" vim:ft=vim tw=78 et sw=2 fdm=marker nowrap:
