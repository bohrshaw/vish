" This is the Vim(Neovim) initialization file dependent on various bundles.
" It's sourced in "init.vim".
"
" Author: Bohr Shaw <pubohr@gmail.com>

" Initialization: {{{1

let $MYBUNDLE = expand('<sfile>') " like $MYVIMRC
let g:statusline = [] " flags to be inserted into 'statusline'

" Let the bundle manager download ALL bundles even if the invoked Vim binary
" doesn't have all these features.
let s:pythonx = (has('python') || has('python3'))
let s:ruby = has('ruby')
let s:lua = has('lua')

call bundle#init() " bundle initialization

" Define local mappings
augroup bundle_map | autocmd!
  execute 'autocmd BufReadPost {.,}'.fnamemodify($MYBUNDLE, ':t')
        \ 'call bundle#map()'
augroup END

" Meta: {{{1

" A Vim plugin for Vim plugins
call BundleRun('Tpope/vim-scriptease')

" Debugging
command! -nargs=? -complete=command VimNORC execute
      \ v:progname.<q-args> =~ '^\S*gvim' ? "B!" : "Start"
      \ empty(<q-args>) ? expand(exepath(v:progpath)) : <q-args>
      \ '-u' expand($MYVIM.'/init.min.vim')
" Profiling
command! -nargs=? -complete=command StartupTime execute
      \ v:progname.<q-args> =~ '^\S*gvim' ? "B!" : "Start"
      \ empty(<q-args>) ? expand(exepath(v:progpath)) : <q-args>
      \ '--startuptime startup.log +qall!' |
      \ tab drop startup.log
command! -nargs=? -complete=command Profile execute
      \ v:progname.<q-args> =~ '^\S*gvim' ? "B!" : "Start"
      \ empty(<q-args>) ? expand(exepath(v:progpath)) : <q-args>
      \ '--cmd "profile start '.getcwd().'/profile.log | profile file *"'
      \ '-c "profdel file * | qall!"' |
      \ tab drop profile.log
command! ProfileTabular call profile#tabular()

" Shortcuts: {{{1

" Pairs of handy bracket mappings
call BundleRun('Tpope/vim-unimpaired')
" Move lines (fix auto-closing folds)
nnoremap <silent>[e :<C-u>call b#unimpaired#move('--', v:count1)<CR>
nnoremap <silent>]e :<C-u>call b#unimpaired#move('+', v:count1)<CR>
xnoremap <silent>[e :<C-u>call b#unimpaired#move("'<--", v:count1)<CR>
xnoremap <silent>]e :<C-u>call b#unimpaired#move("'>+", v:count1)<CR>
nnoremap <silent>]d :call search('\cto-\?do:', 's')<CR>
nnoremap <silent>[d :call search('\cto-\?do:', 'sb')<CR>
nnoremap <silent>[r :set readonly<CR>
nnoremap <silent>]r :set noreadonly<CR>
nmap coP <Plug>unimpairedPaste

" Create your own submodes (e.g, g--- instead of g-g-g-)
" call BundlePath('kana/vim-submode')

" Mappings for simultaneously pressed keys
" call Bundles('kana/vim-arpeggio')

" Motion: {{{1

" The missing motion for Vim
if Bundles('Bohrshaw/vim-sneak') " 'Justinmk/vim-sneak'
  " Arbitrary precise motion
  nnoremap <silent> L :<C-u>call b#sneak#('', 0, '')<CR>
  xnoremap <silent> L :<C-u>call b#sneak#('', 0, 'v')<CR>
  onoremap <silent> L :<C-u>call b#sneak#('', 0, 'o')<CR>
  nnoremap <silent> H :<C-u>call b#sneak#('', 1, '')<CR>
  xnoremap <silent> H :<C-u>call b#sneak#('', 1, 'v')<CR>
  onoremap <silent> H :<C-u>call b#sneak#('', 1, 'o')<CR>
  " Within the current line
  " Note: Don't map `f<CR>`, otherwise IME would be inactive after `f`.
  NXOmap <expr>9f v#setvar('g:sneak#oneline', 1).'L'
  NXOmap <expr>8f v#setvar('g:sneak#oneline', 1).'H'
  " Mimic the native search command / and ?, but literal
  " Function signature: sneak#wrap(op, inputlen, reverse, inclusive, streak)
  nnoremap <silent> z/ :<C-U>call sneak#wrap('', 99, 0, 2, 1)<CR>
  nnoremap <silent> z? :<C-U>call sneak#wrap('', 99, 1, 2, 1)<CR>
  xnoremap <silent> z/ :<C-U>call sneak#wrap(visualmode(), 99, 0, 2, 1)<CR>
  xnoremap <silent> z? :<C-U>call sneak#wrap(visualmode(), 99, 1, 2, 1)<CR>
  onoremap <silent> z/ :<C-U>call sneak#wrap(v:operator, 99, 0, 2, 1)<CR>
  onoremap <silent> z? :<C-U>call sneak#wrap(v:operator, 99, 1, 2, 1)<CR>
  " Repeat
  nnoremap <silent>; :<C-u>call b#sneak#repeat('', 0)<CR>
  xnoremap <silent>; :<C-u>call b#sneak#repeat(visualmode(), 0)<CR>
  onoremap <silent>; :<C-u>call b#sneak#repeat(v:operator, 0)<CR>
  nnoremap <silent>, :<C-u>call b#sneak#repeat('', 1)<CR>
  xnoremap <silent>, :<C-u>call b#sneak#repeat(visualmode(), 1)<CR>
  onoremap <silent>, :<C-u>call b#sneak#repeat(v:operator, 1)<CR>
  let g:sneak#streak = 1 " enable streak mode
  " let g:sneak#streak_esc = "\<CR>" " key to exit streak-mode
  let g:sneak#absolute_dir = 1 " always go forwards or backwards when repeating
  " let g:sneak#use_ic_scs = 1 " ignorecase and smartcase
  hi! link SneakPluginScope Comment
  " Disable default mappings
  NXOmap <Plug>_Sneak_s <Plug>Sneak_s
  NXOmap <Plug>_Sneak_S <Plug>Sneak_S
  let sneak#textobject_z = 0 " prevent the default {operator}z mapping
elseif Dundles('machakann/vim-patternjump')
  let g:patternjump_no_default_key_mappings = 1
elseif Dundles('lokaltog/vim-easymotion')
  let g:EasyMotion_leader_key = 'g<CR>'
elseif Dundles('goldfeld/vim-seek', 'rhysd/clever-f.vim')
  let g:SeekKey = 'f<CR>'
  let g:SeekBackKey = 'f<BS>'
  " let g:seek_enable_jumps = 1
  let g:clever_f_across_no_line = 1
endif

" Create your own text objects
if BundlePath('Kana/vim-textobj-user')
  call textobj#user#plugin('file', {
        \ 'file': {
        \ 'pattern': '\f\+', 'select': ['af', 'if']
        \ }
        \ })
endif

" Text objects extended, more sensible, and corner cases handled
" Cheatsheet: $MYVIM/bundle/targets.vim/cheatsheet.md
" 'gaving/vim-textobj-argument', 'b4winckler/vim-angry', 'qstrahl/vim-dentures'
if Bundles('tommcdo/vim-ninja-feet', 'kana/vim-textobj-indent', 'machakann/vim-textobj-delimited', 'coderifous/textobj-word-column.vim')
  imap <M-g><BS> <Esc>cid
  " Delay activating this bundle to reduce startup time
  if has('vim_starting')
    if has('timers') && !has('nvim') " function() in Neovim is not patched yet
      call timer_start(10, function('BundleRun', ['Wellle/targets.vim']))
    else
      set updatetime=10
      augroup bundle_targets
        autocmd CursorHold * call BundleRun('Wellle/targets.vim') |
              \ set updatetime& | autocmd! bundle_targets
      augroup END
    endif
  endif
endif

" Indent-level based motion
if Bundles('Jeetsukumaran/vim-indentwise')
  map [\| <Plug>(IndentWiseBlockScopeBoundaryBegin)
  map ]\| <Plug>(IndentWiseBlockScopeBoundaryEnd)
endif

" Rich line marks independent from built-in marks
if Dundles('mattesGroeger/vim-bookmarks')
  let g:bookmark_sign = 'm'
  let g:bookmark_annotation_sign = 'ma'
  " let g:bookmark_auto_save = 0
  let g:bookmark_auto_save_file = $MYTMP.'bookmark'
  " let g:bookmark_highlight_lines = 1
  " let g:bookmark_center = 1
  nmap <Leader>tm <Plug>ToggleBookmark
  nmap ma <Plug>Annotate
  nmap ]m <Plug>NextBookmark
  nmap [m <Plug>PrevBookmark
  nmap <Leader>ml <Plug>ShowAllBookmarks
  nmap <Leader>mc <Plug>ClearBookmarks
  nmap <Leader>mC <Plug>ClearAllBookmarks
endif

" Search: {{{1

" Search improved
if Dundles('junegunn/vim-oblique', 'junegunn/vim-pseudocl')
endif

" Search improved
if Bundles('Haya14busa/incsearch.vim') " 'Haya14busa/vim-asterisk'
  " Incremantal search improved with a search specific command line interface
  NXmap g/ <Plug>(incsearch-forward)
  NXmap g? <Plug>(incsearch-backward)
  autocmd User Bundle call s:incsearch_mapping()
  function! s:incsearch_mapping()
    IncSearchNoreMap <M-j> <Over>(incsearch-next)
    IncSearchNoreMap <M-k> <Over>(incsearch-prev)
    IncSearchNoreMap <M-f> <Over>(incsearch-scroll-f)
    IncSearchNoreMap <M-b> <Over>(incsearch-scroll-b)
    IncSearchNoreMap <C-f> <Over>(incsearch-scroll-f)
    IncSearchNoreMap <C-b> <Over>(incsearch-scroll-b)
    IncSearchNoreMap <Tab> <Over>(buffer-complete)
    IncSearchNoreMap <S-Tab> <Over>(buffer-complete-prev)
  endfunction

  let g:incsearch#auto_nohlsearch = 1 " auto-nohlsearch on cursor move
  " Highlight only in the current window (custom hi-group instead of 'Search')
  let g:incsearch#no_inc_hlsearch = 1
endif

" Grep asynchronously
if Bundles('mhinz/vim-grepper')
  cnoreabbrev <expr>ge getcmdtype() == ':' && getcmdpos() == 3 ? 'Grepper -query' : 'ge'
endif

" Completion: {{{1

" Completions
if has('nvim') && Dundles('shougo/deoplete.nvim')
  inoremap <expr><M-h> deoplete#manual_complete()
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#disable_auto_complete = 1
  nnoremap <expr>c\c deoplete#toggle()[1:0]
elseif s:lua && Dundles('shougo/neocomplete.vim')
  let g:neocomplete#enable_at_startup = 0
  let g:neocomplete#max_list = 20
  let g:neocomplete#auto_completion_start_length = 2
  let g:neocomplete#manual_completion_start_length = 1
  " let g:neocomplete#min_keyword_length = 3
  let g:neocomplete#enable_smart_case = &smartcase
  " let g:neocomplete#enable_cursor_hold_i = 1
  " let g:neocomplete#cursor_hold_i_time = 400 " same as swap saving interval
  let g:neocomplete#lock_iminsert = 1
  " let g:neocomplete#enable_prefetch = 1
  let g:neocomplete#data_directory = $MYTMP.'neocomplete'
  " let g:neocomplete#release_cache_time = 1800 " seconds
  " Enable/disable neocomplete
  nnoremap <expr> c<Leader>C neocomplete#is_enabled() ?
        \ ':NeoCompleteDisable<CR>' : ':NeoCompleteEnable<CR>'
  " Toggle auto/manual completion for the current buffer
  nnoremap c<LocalLeader>c :NeoCompleteToggle<CR>
  inoremap <C-g>cc <C-R>=neocomplete#commands#_toggle_lock()[1:0]<CR>
  " Start manual completion
  inoremap <silent><M-n> <C-O>:call neocomplete#init#enable() \|
        \call neocomplete#commands#_lock() \|
        \inoremap <silent><expr><M-n> neocomplete#start_manual_complete()<CR>
        \<C-R>=neocomplete#start_manual_complete()<CR>
elseif Dundles('valloric/youcompleteme')
elseif Dundles('ervandew/supertab')
endif

" Snippet solutions
if s:pythonx && Bundle('Sirver/ultisnips', {
      \ 'm': ['i <M-l>', 'i <C-g>l', 'x <M-l>'],
      \ 'c': 'UltiSnipsEdit',
      \ 'f': 'snippets',
      \ }, 'noftdetect') && Bundles('Honza/vim-snippets')
  let g:UltiSnipsExpandTrigger='<M-l>'
  let g:UltiSnipsListSnippets='<C-g>l'
  let g:UltiSnipsJumpForwardTrigger='<M-j>'
  let g:UltiSnipsJumpBackwardTrigger='<M-k>'

  let g:UltiSnipsSnippetDirectories = ["UltiSnips", "snippet"]
  let g:UltiSnipsSnippetsDir = $MYVIM.'/snippet' " personal snippets path
  " let g:UltiSnipsEnableSnipMate = 0 " don't looking for SnipMate snippets

  let g:UltiSnipsEditSplit = 'context'
  " let g:UltiSnipsUsePythonVersion = has('python3') ? 3 : 2

  " Performance
  let g:UltiSnipsRemoveSelectModeMappings = 0
  let b:did_after_plugin_ultisnips_after = 1 " I don't have SuperTab
elseif Dundles('garbas/vim-snipmate', 'marcweber/vim-addon-mw-utils', 'tomtom/tlib_vim', 'honza/vim-snippets')
  command! -nargs=1 SImap imap <args>|smap <args>
  SImap <M-j> <Plug>snipMateNextOrTrigger
  xmap <M-j> <Plug>snipMateVisual
  SImap <M-k> <Plug>snipMateBack
  SImap <M-s> <Plug>snipMateShow
endif
let g:snips_author = 'Bohr Shaw'
let g:snips_author_email = 'pubohr@gmail.com'

" Change: {{{1

" Commenting
" 'scrooloose/nerdcommenter', 'tomtom/tcomment_vim'
if Bundles('Tpope/vim-commentary')
  let commentary_map_backslash = 0 " jd
  let g:tcommentMapLeader1 = '<M-c>'
  let [g:tcommentMapLeader2, g:tcommentMapLeaderCommentAnyway, g:tcommentTextObjectInlineComment] = ['', '', '']
endif

" Deal with pairs of 'surroundings'
if Bundles('Tpope/vim-surround')
  " :help ys
  nmap s      <Plug>Ysurround
  nmap ss     <Plug>Yssurround
  nmap ds     <Plug>Dsurround
  nmap cs     <Plug>Csurround
  " :help yS
  nmap gs     <Plug>YSurround
  nmap gss    <Plug>YSsurround
  nmap gcs    <Plug>CSurround
  " :help vS
  xmap s      <Plug>VSurround
  xmap gs     <Plug>VgSurround
  " :help i_CTRL-G_s
  " imap     <M-s>       <Plug>Isurround
  imap     <M-S>       <Plug>ISurround
  imap     <C-g>s      <Plug>ISurround
  noremap! <expr><M-s> b#surround#()

  " Surround replacements
  " let g:surround_{char2nr('s')} = '`\r`' " doesn't work
  let g:surround_{char2nr("\<M-[>")} = "[[ \r ]]"
  let g:surround_{char2nr("\<M-9>")} = "(( \r ))"
  let g:surround_{char2nr('e')} = " \r " " e(empty) as <Space>
  let g:surround_{char2nr("\<CR>")} = "\n\t\r\n"
  " Won't insert indents
  nmap ss<CR> sVl<CR>

  " Surround targets
  " Delete the nearest <Space>s around the cursor
  nnoremap <silent>dse mz:execute 'keepp s/\v\s*(\S*%#\S*)\s*/\1'<Bar>
        \call repeat#set("dse")<CR>g`z

  let g:surround_indent = 1
  let g:surround_no_mappings = 1
endif
" Provides insert mode auto-completion for quotes, parens, brackets, etc.
" call Bundles('raimondi/delimitmate', 'cohama/lexima.vim', 'jiangmiao/auto-pairs')
" Wisely add 'end' in ruby, endfunction/endif/more in vim script, etc
if Bundles('Tpope/vim-endwise')
  autocmd User Bundle autocmd! endwise CmdwinEnter
endif

" Switch segments of text with predefined replacements
if Bundle('Andrewradev/switch.vim', {'c': ['Switch', 'SwitchReverse']})
  nnoremap <silent>s<CR> :Switch<CR>
  nnoremap <silent>s<BS> :SwitchReverse<CR>
  " let g:switch_custom_definitions = []
  let g:switch_mapping = ''
  let g:switch_reverse_mapping = ''
endif

" Transition between multiline and single-line code
if Bundles('andrewradev/splitjoin.vim')
  let g:splitjoin_split_mapping = 'cS'
  let g:splitjoin_join_mapping  = 'cJ'
endif

" Alignment
if Bundle('junegunn/vim-easy-align',
      \ {'m': ['nx <Plug>(EasyAlign)', 'nx <Plug>(LiveEasyAlign)'],
      \ 'c': ' EasyAlign'})
  command! -nargs=* -range -bang Align <line1>,<line2>EasyAlign<bang> <args>
  NXmap zl <Plug>(EasyAlign)
  NXmap Zl <Plug>(LiveEasyAlign)
endif
if Dundles('godlygeek/tabular') " 'tommcdo/vim-lion'
  AddTabularPipeline! spaces /\s/
        \ map(a:lines, "substitute(v:val, '  *', ' ', 'g')") |
        \ tabular#TabularizeStrings(a:lines, '\s', 'l0')
endif

" Use CTRL-A/CTRL-X to increment dates, times, and more
call Bundles('tpope/vim-speeddating')

" Exchange text flexibly with a text exchange operator
if Bundles('Tommcdo/vim-exchange')
  nmap >w cxiwwcxiw
  nmap <w cxiwbcxiw
  nmap >W cxiWWcxiW
  nmap <W cxiWBcxiW
  nmap >a cxiaf,lcxia
  nmap <a cxiaF,hcxia
endif
" Exchange(swap) text directly/quickly with mappings
if Dundles('kurkale6ka/vim-swap')
  " let g:swap_custom_ops = []
  xmap c: <plug>SwapSwapOperands
  xmap c<Leader>\| <plug>SwapSwapPivotOperands
endif

" Transpose matrices of text (swap lines with columns)
call Bundles('salsifis/vim-transpose')

" Easily search for, substitute, and abbreviate multiple variants of a word
call Bundles('Tpope/vim-abolish')

" True Sublime Text style multiple selections for Vim
if Dundle('terryma/vim-multiple-cursors', {'m': ['n <C-n>', 'x <C-n>']})
  " let g:multi_cursor_exit_from_visual_mode = 0
  let g:multi_cursor_exit_from_insert_mode = 0
endif

" Preview contents of the registers when ", @, i_CTRL-R
" call Dundles('junegunn/vim-peekaboo')

" Make the handling of unicode and digraphs easier
call Bundle('tpope/vim-characterize', {'m': 'n ga'})
if Bundles('chrisbra/unicode.vim')
  imap <C-x><M-u> <Plug>(UnicodeComplete)
  imap <C-x><M-d> <Plug>(DigraphComplete)
  nmap gA <Plug>(UnicodeGA)
  " Disable mappings
  nmap <leader>_MakeDigraph <Plug>(MakeDigraph)
  nmap <leader>_UnicodeSwapCompleteName <Plug>(UnicodeSwapCompleteName)
  " Duplicate commands with new names
  command! -nargs=1 Unicode call unicode#PrintUnicode(<q-args>)
  command! UnicodeDownload call unicode#Download(1)
endif

" Replay the edit
" call Bundles('chrisbra/replay', 'haya14busa/vim-undoreplay')

" Repeat: {{{1

" Visualize the undo tree/history
if has('nvim') ?
      \ Bundle('Simnalamburt/vim-mundo', {'m': [
      \ 'nnoremap <silent>c<LocalLeader>u :GundoToggle<CR>',
      \ 'nnoremap <silent>c<LocalLeader>U :GundoRenderGraph<CR>']}) :
      \ Bundle('Sjl/gundo.vim', {'m':
      \ 'nnoremap <silent>c<LocalLeader>u :GundoToggle<CR>'})
  augroup bundle_gundo | autocmd!
    autocmd BufNewFile __gundo*
        \ nnoremap <buffer><expr><nowait>R
        \   ':let g:gundo_auto_preview = '.!g:gundo_auto_preview.
        \   " <Bar> normal r<CR>"|
        \ nmap <buffer><M-q> q
  augroup END
  let g:gundo_close_on_revert = 1 " auto-close the Gundo window
  let g:gundo_auto_preview = 0
  let g:gundo_playback_delay = 500
  " let g:gundo_help = 0
endif
if Dundles('mbbill/undotree')
  nnoremap <silent><M-b>u :UndotreeToggle<CR>
  let g:undotree_SetFocusWhenToggle = 1 " cursor on the Undo window
endif

" Enable repeating supported plugin maps with '.'
call Bundles('Tpope/vim-repeat')

" A lightweight implementation of emacs's kill-ring for vim
" call Bundles('maxbrunsfeld/vim-yankstack')

" View: {{{1

" Distraction-free, hyper-focus writing
if Bundle('junegunn/goyo.vim', {'c': 'Goyo'}) &&
      \ Bundle('junegunn/limelight.vim', {'c': 'Limelight'})
  " let g:goyo_width = 100
  let g:goyo_margin_top = 2
  let g:goyo_margin_bottom = 2
  " let g:goyo_linenr = 1
  nnoremap <silent><C-W><M-o> :Goyo<CR>
  " autocmd User GoyoEnter Limelight
  " autocmd User GoyoLeave Limelight!
endif

" Resize windows using Golden Ratio (Mnemonic: golden :only)
if Bundle('roman/golden-ratio', {'m':
      \ 'nmap <silent><C-w>go <Plug>(golden_ratio_toggle)'})
  let g:golden_ratio_autocommand = 0
endif

" Interface: {{{1

" Fuzzy file, buffer, mru, tag, etc finder
if Dundles('ctrlpvim/ctrlp.vim')
  let g:ctrlp_cache_dir = $MYTMP.'ctrlp'
  " Set the mode to determine the root searching directory.
  " let g:ctrlp_working_path_mode = 'ra'
  " let g:ctrlp_show_hidden = 1 " scan for dotfiles and dotdirs
  let g:ctrlp_follow_symlinks = 1
  " let g:ctrlp_clear_cache_on_exit = 0
  let g:ctrlp_max_files = 0
  let g:ctrlp_lazy_update = 99 " update the match window lazily
  " let g:ctrlp_by_filename = 1 " search by file name only
  let g:ctrlp_custom_ignore = {
        \ 'dir':  '\v[\/]\.(git|hg|svn)$',
        \ 'file': '\v\.(exe|so|dll)$'
        \ }
  " Specify an external tool to use for listing files.
  let s:ctrlp_git_cmd = 'cd %s && git ls-files --cached --others --exclude-standard'
  let g:ctrlp_user_command = {
        \ 'types': {
        \ 1: ['.git', has('win32') ? '('.s:ctrlp_git_cmd.')' : s:ctrlp_git_cmd],
        \ 2: ['.hg', 'hg --cwd %s locate -I .'],
        \ },
        \ 'fallback': !has('win32') ?
        \ 'find %s -path "*/\.*" -prune -o -type f -print -o -type l -print' :
        \ executable('ag') ? 'ag -g "" %s' : ''
        \ }
  " Mappings inside CtrlP's prompt
  let g:ctrlp_prompt_mappings = {
        \ 'PrtCurLeft()':         ['<C-b>'],
        \ 'PrtCurRight()':        ['<C-f>'],
        \ 'PrtInsert()':          ['<C-r>'],
        \ 'PrtInsert("c")':       ['<C-S-v>'],
        \ 'ToggleRegex()':        ['<M-r>'],
        \ 'ToggleByFname()':      ['<M-d>'],
        \ 'PrtSelectMove("j")':   ['<M-j>'],
        \ 'PrtSelectMove("k")':   ['<M-k>'],
        \ 'MarkToOpen()':         ['<M-m>'],
        \ 'AcceptSelection("h")': ['<M-w>s'],
        \ 'AcceptSelection("v")': ['<M-w>v'],
        \ 'AcceptSelection("t")': ['<M-w>t'],
        \ 'CreateNewFile()':      ['<C-n>'],
        \ 'ToggleType(1)':        ['<M-f>'],
        \ 'ToggleType(-1)':       ['<M-b>'],
        \ 'PrtExit()':            ['<Esc>', '<C-c>', '<M-q>', '<C-g>'],
        \ }
  " Find project files
  let g:ctrlp_map = '<M-f>p'
  " Most recent used files
  nnoremap <Leader>fr :CtrlPMRU<CR>
  " Files with similar names
  nmap <Leader>fs :let g:ctrlp_default_input = expand('%:t:r') \|
        \ call ctrlp#init(0) \| unlet g:ctrlp_default_input<CR>
  " Buffers
  nnoremap <Leader>fb :CtrlPBuffer<CR>
  " Files, buffers and MRU files at the same time
  nnoremap <Leader>fa :CtrlPMixed<CR>
  " Bookmarked directories
  nnoremap <leader>fm :CtrlPBookmarkDir<CR>
  " Clear the cache for the current search path
  nnoremap <leader>fc :CtrlPClearCache<CR>
  " fast matcher(especially for large projects) using python
  if s:pythonx && Dundles('felikz/ctrlp-py-matcher')
    let g:ctrlp_match_func = {'match': 'pymatcher#PyMatch'}
  elseif Dundles('tpope/vim-haystack') " better fuzzy matching algorithm
    let g:ctrlp_match_func = {'match': 'b#haystack#'}
  endif
  " Extensions
  let g:ctrlp_extensions = []
  " Navigate and jump to function defs
  if Dundles('tacahiroy/ctrlp-funky')
    call add(g:ctrlp_extensions, 'funky')
    nnoremap <Leader>ff :CtrlPFunky<CR>
  endif
  " Modified files in git projects
  if Dundles('jasoncodes/ctrlp-modified.vim')
    nnoremap <Leader>fg :CtrlPModified<CR>
  endif
endif

" Unite and create user interfaces
" call Bundles('shougo/denite.nvim')
" 'shougo/tabpagebuffer.vim', 'kopischke/unite-spell-suggest'
if DundlePath('shougo/unite.vim') &&
      \ Dundles('thinca/vim-unite-history', 'shougo/neomru.vim', 'shougo/unite-outline', 'tsukkee/unite-tag', 'shougo/unite-help')
  command! -nargs=* -complete=customlist,unite#complete#source U Unite <args>
  command! -nargs=? -complete=customlist,unite#complete#buffer_name Ur UniteResume <args>
  " The key <M-b> prefixes all mappings related to 'internal' contents
  nnoremap <silent><M-b>l :Unite -buffer-name=buffer buffer<CR>
  nmap <M-b>o <M-b>l
  nnoremap <silent><M-b>L :Unite -direction=above -prompt-direction=above line<CR>
  nnoremap <silent><M-b>O :Unite -direction=above -prompt-direction=above outline<CR>
  nnoremap <silent><M-b>j :Unite jump<CR>
  nnoremap <silent><M-b>c :Unite change<CR>
  nnoremap <silent><M-b>r :Unite register<CR>
  nnoremap <silent><M-b>h :Unite -buffer-name=help -input=.txt\ doc/ buffer:?<CR>
  nnoremap <silent><M-b>H :Unite help<CR>
  " The key <M-f> relates to 'external' contents
  nnoremap <silent><M-f>l :Unite file:<C-r>=escape(expand('%:h'), '\')<CR><CR>
  nnoremap <silent><M-f>L :Unite file<CR>
  nnoremap <silent><M-f>p :call b#unite#files_project()<CR>
  nnoremap <silent><M-f>r :Unite file_mru<CR>
  nnoremap <silent><M-f>m :Unite bookmark<CR>
  " The key <M-u> relates to utilities or Unite itself
  nnoremap <silent><M-u>c :Unite history/command<CR>
  nnoremap <silent><M-u>m :Unite mapping:%<CR>
  nnoremap <silent><M-u>f :Unite function<CR>
  nnoremap <silent><M-u>s :Unite source<CR>
  nnoremap <silent><M-u>r :UniteResume<CR>
  nnoremap <silent>]<M-u> :UniteNext<CR>
  nnoremap <silent>[<M-u> :UnitePrevious<CR>
  " Custom mappings for unite buffers
  augroup bundle_unite | autocmd!
    autocmd FileType unite call b#unite#map()
  augroup END
  call unite#custom#profile('default', 'context', {
        \'start_insert': 1,
        \'direction': 'belowright',
        \'prompt_direction': 'below',
        \'auto_resize': 1,
        \})
  if executable('ag')
    if has('win32')
      let g:unite_source_rec_async_command = ['ag', '-g', '']
    endif
    let g:unite_source_grep_command='ag'
    let g:unite_source_grep_default_opts='--line-numbers'
    let g:unite_source_grep_recursive_opt=''
  endif
  " call unite#filters#matcher_default#use(['matcher_fuzzy'])
  " let g:unite_source_history_yank_enable = 1 " yank ring
  let g:unite_data_directory = $MYTMP.'unite'
  let g:neomru#file_mru_path = $MYTMP.'unite/mru/files'
  let g:neomru#directory_mru_path = $MYTMP.'unite/mru/directories'
  " Performance tuning
  " let g:neomru#do_validate = 0 " skip checking invalide files for performance
  autocmd User Bundle silent! autocmd! neomru BufEnter,VimEnter,BufWritePost
endif

" A command-line fuzzy finder
if (Bundles('junegunn/fzf') ||
      \ isdirectory($HOME.'/.fzf/plugin') && rtp#add('~/.fzf')) &&
      \ Bundles('junegunn/fzf.vim')
  let g:fzf_command_prefix = ''
  nnoremap <silent><M-f>l :call fzf#vim#files(expand('%:h'), 0)<CR>
  nnoremap <silent><M-f>L :Files<CR>
  nnoremap <silent><M-f>g :GitFiles<CR>
  nnoremap <silent><M-f>s :GitFiles?<CR>
  nnoremap <silent><M-f>r :History<CR>
  nnoremap <silent><M-b>l :Buffers<CR>
  nnoremap <silent><M-b>m :Marks<CR>
  imap <C-x>F <plug>(fzf-complete-path)
  imap <expr><C-x>K b#fzf#dict()
  let g:fzf_action = {
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit',
        \ 'ctrl-t': 'tab split',
        \ 'alt-t': '-tab split',
        \ }
  let $FZF_DEFAULT_OPTS = '--exact --multi --cycle'
endif

" A tree explorer plugin for vim
if Dundle('scrooloose/nerdtree', {'m': [
      \ 'nnoremap c<Leader>d :NERDTreeToggle<CR>',
      \ 'nnoremap <leader>dd :NERDTree<CR>',
      \ 'nnoremap <leader>df :NERDTreeFind<CR>']})
  let NERDTreeHijackNetrw=0 " don't replace netrw
  let NERDTreeBookmarksFile=$MYTMP.'NERDTreeBookmarks'
  let NERDTreeIgnore=['^\.$', '^\.\.$', '\~$', '\.pyc$', '\.swp$']
  let NERDTreeShowHidden=1
  let NERDTreeShowBookmarks=1
  let NERDTreeQuitOnOpen=1
  let NERDTreeMouseMode=2
endif
" A minimalist directory viewer intended to be composable
if Bundles('Justinmk/vim-dirvish')
  nmap <silent><M-f>h :<C-u>Dirvish %:p<C-r>=repeat(':h',v:count1)<CR><CR>
  nmap <M--> <M-f>h
  nmap <silent><M-f>. :Dirvish<CR>
  autocmd User Bundle nunmap -
elseif Dundles('tpope/vim-vinegar') " 'jeetsukumaran/vim-filebeagle'
  nmap <M-f>h <Plug>VinegarUp
  autocmd User Bundle nunmap -
endif

" Project configuration
" call Bundles('tpope/vim-projectionist')

" Buffer Explorer/Browser
" call Bundles('vim-scripts/bufexplorer.zip', 'jeetsukumaran/vim-buffergator')

" Workflow: {{{1

" Session management
if Bundles('bohrshaw/vim-mansion') " 'tpope/vim-obsession'
  let g:sessiondir = $MYVIM.'/session'
  " let g:mansion_no_auto_save = 1
  " let g:mansion_no_maps = 1
elseif Dundles('mhinz/vim-startify')
  let g:startify_session_dir = $MYVIM.'/session'
  let g:startify_list_order = ['sessions', 'bookmarks', 'files']
  let g:startify_skiplist = ['[Vv]im.*[\/]doc[\/][^\/]\+\.txt']
  let g:startify_custom_header = [
        \ '   _   /|',
        \ "   \\'o.O'",
        \ '   =(___)=',
        \ '      U    ʕϴϖϴʔ',
        \ ''
        \ ]
  " Prevent CtrlP open a split
  augroup bundle_startify | autocmd!
    autocmd FileType startify setlocal nospell buftype=
  augroup END
endif

" Appearance: {{{1

" Color Schemes
if Bundles('Bohrshaw/vim-colors', 'Chriskempson/base16-vim')
  autocmd User Bundle nested execute 'silent color'
        \ has('nvim') || has('gui_running') || !has('win32') ?
        \   &background == 'light' ? 'seoul256' : 'seoul256' :
        \   ''
  augroup bundle_colors | autocmd!
    autocmd ColorScheme * call b#colors#()
  augroup END

  let g:seoul256_background = 233
  let g:gruvbox_italic = 0
  let g:solarized_italic = 0
  let g:solarized_underline = 0
  let g:solarized_termcolors = &term =~ '256col' ? 256 : 16
  let g:solarized_menu=0
endif

" All 256 xterm colors with their RGB equivalents, right in Vim!
if Bundle('guns/xterm-color-table.vim', {'c': 'XtermColorTable'})
  command! ColorTable XtermColorTable
endif

" A powerful color tool
" call Bundles('rykka/colorv.vim')

" Make gvim-only colorschemes work transparently in terminal vim
" call Bundles('godlygeek/csapprox')

" Enhances Vim's integration with the terminal in several ways
if !has('gui_running') && Dundles('wincent/terminus')
endif

" Lean & mean statusline for vim that's light as air
if Dundles('bling/vim-airline')
  " Remove separators, the different colors already make it easy to distinguish.
  let [g:airline_left_sep, g:airline_right_sep] = ['', '']
  " let g:airline_paste_symbol = 'P'
  let g:airline_section_z = '%l,%c %p%%' "right side section
  " Use shorter modes indicators
  let g:airline_mode_map = { '__': '-', 'n': 'N', 'i': 'I', 'R': 'R', 'c': 'C',
        \ 'v': 'V', 'V': 'VL', '': 'VB', 's': 'S', 'S': 'SL', '': 'SB'}
  " Extensions
  " Disable showing a summary of changed hunks under source control.
  let g:airline#extensions#hunks#enabled = 0
  " Showing only non-zero hunks.
  let g:airline#extensions#hunks#non_zero_only = 1
  " Disable detection of whitespace errors.
  let g:airline#extensions#whitespace#enabled = 0
  " Disable tagbar integration.
  let g:airline#extensions#tagbar#enabled = 0
endif

" Super simple vim plugin to show the list of buffers in the command bar
" call Bundles('bling/vim-bufferline')

" Toggle, display and navigate marks
if Dundles('kshenoy/vim-signature')
  let g:SignatureEnabledAtStartup = 0
  let g:SignatureMenu = 0
endif

" Displaying indent levels visually
if Bundle('yggdroot/indentline', {'m':
      \ 'nnoremap <silent>c<LocalLeader>d :IndentLinesToggle<CR>'})
  " 'nathanaelkane/vim-indent-guides'
  let g:indentLine_enabled = 0
  let g:indentLine_fileTypeExclude = ['help']
  let g:indentLine_noConcealCursor = ''
  " let g:indentLine_fileType = ['rb']
  " let g:indentLine_faster = 1
  " let g:indentLine_char = '┊' " |│¦┆┊
endif

" Toggle full screen
if has('win32')
  if Dundle('bohrshaw/wimproved.vim:', {'c': 'WToggleFullscreen'})
    " 'kkoenig/wimproved.vim'
    command! FullScreen WToggleFullscreen
  elseif executable('gvimfullscreen.dll')
    command! FullScreen call libcallnr('gvimfullscreen.dll', "ToggleFullScreen", 0)
  endif
endif

" Neovim-qt: helper GUI commands and functions (bundled in ginit.vim)
Nop call Bundles('equalsraf/neovim-gui-shim')

" FileTypes: {{{1

" A collection of language packs
" call Bundle('sheerun/vim-polyglot')

" Tools {{{2

" Syntax checking hacks for vim
if !has('nvim') && Bundles('scrooloose/syntastic')
  let g:syntastic_mode_map = { 'mode': 'active',
        \ 'active_filetypes': [],
        \ 'passive_filetypes': [] }
  let g:syntastic_auto_loc_list = 0
  " let g:syntastic_always_populate_loc_list = 1
  " let g:syntastic_auto_jump = 3 " auto-jump to the first error
elseif Bundles('benekastah/neomake')
  command! -nargs=* -bang -bar -complete=customlist,neomake#CompleteMakers M
        \ Neomake<bang> <args>
  augroup bundle_neomake | autocmd!
    autocmd BufWritePost * Neomake
    autocmd BufWinEnter * call neomake#ProcessCurrentWindow()
    autocmd User Bundle autocmd! neomake
  augroup END
  nnoremap <silent>sm :call neomake#EchoCurrentError()<CR>
endif

" Format codes with external code formatters
if Bundle('chiel92/vim-autoformat', {'c': 'Autoformat'})
endif

" Vim plugin that displays tags in a window, ordered by class etc
if Bundle('majutsushi/tagbar', {'m': [
      \ 'nnoremap <silent>c<Leader>t :TagbarToggle<CR>',
      \ 'nnoremap <silent>c<Leader>T :TagbarTogglePause<CR>']})
  let g:tagbar_map_toggleautoclose = "C"
  let g:tagbar_autoclose = 1

  let g:tagbar_map_preview = "p"
  let g:tagbar_map_showproto = "i"
  let g:tagbar_map_hidenonpublic = "P"
  let g:tagbar_map_togglesort = "S"
  let g:tagbar_sort = 0
  let g:tagbar_map_zoomwin = "X"
  let g:tagbar_zoomwidth = 0
  let g:tagbar_compact = 1
  let g:tagbar_foldlevel = 2
endif

" Documentation/reference viewer
if Bundle('keithbsmiley/investigate.vim',
      \ {'m': 'nnoremap <silent>gK :call investigate#Investigate()<CR>'})
endif
if Dundles('thinca/vim-ref')
  let g:ref_no_default_key_mappings = 1
  nmap gK <Plug>(ref-keyword)
  xmap gK <Plug>(ref-keyword)
endif
" Reference docs using an external tool 'zeal' (poor VimL)
if Bundle('KabbAmine/zeavim.vim', {'m': 'nnoremap <silent>zK :Zeavim<CR>'})
  " Or set a local docset with :Docset which actually just set b:manualDocset
  let g:zv_added_files_type = {
        \ 'python': 'python 3',
        \ 'ruby': 'ruby 2',
        \ }
  let g:zv_disable_mapping = 1
endif

" Dispatch.vim: asynchronous build and test dispatcher
" call Bundles('tpope/vim-dispatch')

" Run Async Shell Commands in Vim 8.0
if Bundles('skywind3000/asyncrun.vim')
  call insert(g:statusline, "%{get(g:, 'asyncrun_status', '')}")
  " Override the command provided by "vim-dispatch" to make :Gpull asynchronous
  autocmd User Bundle command! -bang -nargs=* -complete=file
        \ Make AsyncRun -program=make @ <args>
endif

" Execute whole/part of editing file
if Bundles('thinca/vim-quickrun')
  command! -nargs=* -range=% -complete=customlist,quickrun#complete Run
        \ call quickrun#command(<q-args>, <count>, <line1>, <line2>)
  nmap R <Plug>(quickrun-op)
  xnoremap <silent>R :Run -mode v<CR>
  nnoremap <silent>Rr :.Run -mode n<CR>
  nnoremap <silent>RR :Run -mode n<CR>

  " Echo the value of an expression, or preview markdown
  nnoremap <silent>Re :set operatorfunc=run#eval<CR>g@
  nnoremap <silent>RE :Preview<CR>
  xnoremap <silent>gR "zy:call run#eval('v')<CR>
  " Preview markdown in a browser
  command! -nargs=* -range=% -complete=customlist,quickrun#complete Preview
        \ <line1>,<line2>Run -type markdown_preview

  " Configure the runner for various file types.
  " See the value of g:quickrun#default_config for examples.
  let g:quickrun_config = {
        \ '_': {'outputter': 'message'},
        \
        \ 'sh': {'command': 'bash'},
        \ 'lua': {'command': executable('luajit') ? 'luajit' : 'lua'},
        \
        \ 'markdown': {'type':
        \ executable('pandoc') ? 'markdown/pandoc' :
        \ executable('cmark') ? 'markdown/cmark' :
        \ executable('redcarpet') ? 'markdown/redcarpet' :
        \ ''},
        \ 'markdown_preview': {
        \ 'type': executable('pandoc') ? 'markdown/pandoc_highlight' : 'markdown',
        \ 'outputter': 'browser',
        \ },
        \ 'markdown/pandoc': {'command': 'pandoc',
        \ 'cmdopt': '--from markdown_github --no-highlight',
        \ },
        \ 'markdown/pandoc_highlight': {'command': 'pandoc',
        \ 'cmdopt': '--from markdown_github --standalone',
        \ },
        \ 'markdown/cmark': {'command': 'cmark',
        \ 'cmdopt': '--hardbreaks',
        \ },
        \ }
  if empty(g:quickrun_config.markdown.type)
    call remove(g:quickrun_config, 'markdown')
  endif

  let g:quickrun_no_default_key_mappings = 1
endif
" Run code on codepad.org
if Bundle('mattn/codepad-vim', {'m': [
      \ 'nnoremap <Leader>R :CodePadRun<CR>',
      \ 'xnoremap <Leader>R :CodePadRun<CR>']})
endif

" Rainbow Parentheses
if Bundle('junegunn/rainbow_parentheses.vim', {
      \ 'm': 'nnoremap <silent>c<LocalLeader>r :call rainbow_parentheses#toggle()<CR>',
      \ 'c': 'RainbowParentheses'})
  augroup bundle_rainbow_parentheses | autocmd!
    autocmd FileType lisp,clojure,scheme RainbowParentheses
  augroup END
  " let g:rainbow#pairs = [['(', ')'], ['[', ']']]
  " List of colors that you do not want. ANSI code or #RRGGBB
  " let g:rainbow#blacklist = [233, 234]
  " let g:rainbow#max_level = 12
endif

" Markups {{{2

" HTML5 omnicomplete and syntax
call Bundle('othree/html5.vim', {'f': 'html'})

" Runtime files for Haml, Sass, and SCSS
call Bundle('tpope/vim-haml', {'f': 'haml,sass,scss'})

" XML
let g:xml_syntax_folding = 1

" Runtime files for LESS (dynamic CSS)
call Bundle('groenewege/vim-less', {'f': 'less'})

" Improves HTML & CSS workflow: http://emmet.io
if Bundle('mattn/emmet-vim', {'m': 'i <C-x>e'}) " rstacruz/sparkup
  let g:user_emmet_mode='i' " only enabled in insert mode
  let g:user_emmet_leader_key = '<C-x>e' " mnemonic of 'expand'
  " let g:user_emmet_install_global = 0 " enabled only for certain file types
  " autocmd bundle FileType html,css EmmetInstall
endif

" Markdown runtime files
if Bundle('tpope/vim-markdown', {'f': 'markdown'})
  let g:markdown_folding = 1
endif

" Preview various markup files with external tools
" Note: This is superseded by QuickRun.
if Dundles('greyblake/vim-preview') " 'matthias-guenther/hammer.vim'
  nnoremap <silent>RE :Preview<CR>
  autocmd User Bundle nunmap <Leader>P
  " The markdown rendering gem 'redcarpet' is unavailable on Windows
  if has('win32')
    autocmd User Bundle command! -range=% PreviewMarkdown
          \ call markdown#preview(<line1>, <line2>)
    nnoremap <silent><expr>RE ':Preview'.
          \ (&filetype == 'markdown' ? 'Markdown' : '')."<CR>"
  endif
endif

" Javascript {{{2

" Vastly improved Javascript indentation and syntax support
call Bundle('pangloss/vim-javascript', {'f': 'javascript'})

" A plugin that integrates JSHint with Vim
" call Bundles('walm/jshint.vim')

" Tern plugin for vim(provides Tern-based JavaScript editing support)
" call Bundles('marijnh/tern_for_vim')

" CoffeeScript support for vim
call Bundle('kchmck/vim-coffee-script', {'f': 'coffee'})

" CFamily {{{2

if Bundle('rust-lang/rust.vim', {'f': 'rust'})
  let g:rust_fold = 1 " folds are defined but opened
  " let g:rust_conceal = 1
  augroup bundle_rust | autocmd!
    autocmd FileType rust
          \ nnoremap <buffer>RR :RustRun<CR>|
          \ nnoremap <buffer>R<Space> :RustRun
  augroup END
endif

" Golang {{{2

if Bundles('fatih/vim-go')
  nnoremap <expr>g<LocalLeader> ':Go'.toupper(v#getchar())
  let g:go_auto_type_info = 0
  let g:go_fmt_autosave = 0
  " let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
  let g:go_dispatch_enabled = 0
  let g:go_highlight_string_spellcheck = 0
  let g:go_highlight_trailing_whitespace_error = 0 " covered by 'listchars'
  let g:go_term_mode = "split"

  augroup bundle_go | autocmd!
    autocmd FileType godoc nnoremap <buffer>q <C-W>q
    " For :GeDoc
    autocmd BufReadCmd godoc://*
          \ nmap <buffer><CR> <C-]>|
          \ nmap <buffer><BS> <C-t>|
          \ nmap <buffer><LocalLeader>p <C-a>|
          \ nnoremap <buffer>q <C-w>q|
          \ stopinsert
  augroup END

  let g:go_bin_path = has('win32unix') ?
        \ '/cygdrive/'.tolower($GOPATH[0]).
        \   substitute($GOPATH[2:], '\\', '/', 'g').'/bin/' :
        \ expand("$GOPATH/bin/")
  let g:go_disable_autoinstall = 1 " run in another instance to be asynchronous
  let g:go#use_vimproc = 0 " path problem on Windows
  " call add(g:syntastic_mode_map['passive_filetypes'], 'go')

  if Bundle('garyburd/go-explorer', {'c': 'GeDoc'}) " abandoned
    command! -nargs=* -complete=customlist,ge#complete#complete_package_id
          \ GoD GeDoc <args>
  endif
endif

" Ruby {{{2

" Ruby runtime files (more updated than the one shipped with Vim)
if Bundle('vim-ruby/vim-ruby', {'f': 'ruby'})
endif

" Ruby text objects
if Bundle('rhysd/vim-textobj-ruby', {'f': 'ruby'})
  " Omap irr(any), iro(object), irc(control), ird(do), irl(loop)
  let g:textobj_ruby_more_mappings = 1
elseif Dundle('nelstrom/vim-textobj-rubyblock', {'f': 'ruby'})
endif

" Runs RuboCop(A robust Ruby code analyzer)
if Bundle('ngmy/vim-rubocop', {'f': 'ruby'})
  let g:vimrubocop_keymap = 0
  augroup bundle_rubocop | autocmd!
    autocmd FileType ruby nnoremap <silent><buffer> Rl :RuboCop<CR>
  augroup END
endif

" Bindings for the gem recording the results of every line of code
if Dundles('hwartig/vim-seeing-is-believing')
  augroup bundle_seeing_is_believing | autocmd!
    autocmd FileType ruby
        \ NXInoremap <buffer> <F5> <Plug>(seeing-is-believing-run)|
        \ NXInoremap <buffer> <F4> <Plug>(seeing-is-believing-mark)
  augroup END
endif

" Vim plugin for debugging Ruby applications (using ruby-debug-ide gem)
" call Bundles('astashov/vim-ruby-debugger')

" It's like rails.vim without the rails
call Bundle('tpope/vim-rake', {'f': 'ruby'})

" Python {{{2

" Vim python-mode. PyLint, Rope, Pydoc, breakpoints from box.
" (Known to conflict with 'jedi-vim'.)
if Dundles('klen/python-mode')
  let g:pymode_run_bind = '<LocalLeader>r'
  let g:pymode_breakpoint_bind = '<LocalLeader>b'
  let g:pymode_rope = 0
  " Escape syntastic check for python
  call add(get(get(g:, 'syntastic_mode_map', {}), 'passive_filetypes', []), 'python')
  let g:pymode_python = 'python3'
  autocmd User Bundle set shellslash&
endif

" Bindings for the python auto-completion library 'jedi'
if s:pythonx && Bundle('davidhalter/jedi-vim', {'f': 'python'})
  let g:jedi#goto_assignments_command = 'gd'
  let g:jedi#goto_command = 'gD'
  let g:jedi#rename_command = '<LocalLeader>r'
  let g:jedi#usages_command = '<LocalLeader>u'
  " let g:jedi#use_tabs_not_buffers = 1
  " let g:jedi#use_splits_not_buffers = 'winwidth'

  " Completion
  let g:jedi#show_call_signatures = 2 " show it in the command line

  " let g:jedi#force_py_version = has('python3') ? 3 : 2
  nnoremap c<Leader>p :call jedi#force_py_version_switch()<CR>

  " Let g:jedi#auto_initialization = 0
  let g:jedi#auto_vim_configuration = 0
  let g:jedi#completions_command = '' " don't map for omni completion
endif

" A nicer Python indentation style
" call Bundles('hynek/vim-python-pep8-indent/')

" A two-way integration between Vim and IPython 0.11+
" call Bundles('ivanov/vim-ipython')

" JavaJVM {{{2

" Set 'path' from the Java class path
call Bundle('tpope/vim-classpath', {'f': 'clojure,groovy,java,scala'})

" My work on integration of Scala into Vim - not a ton here, but useful for me
" call Bundles('derekwyatt/vim-scala')

" Clojure {{{2

" Clojure runtime files (shipped with Vim)
call Bundle('guns/vim-clojure-static', {'f': 'clojure'})
" let g:clojure_fold = 1 " Fold list/vector/map that extends over multi-lines

" Clojure REPL support
call Bundle('tpope/vim-fireplace', {'f': 'clojure'})

" Static support for Leiningen
if !has('win32unix') && Bundle('tpope/vim-leiningen', {'f': 'clojure'})
endif

" Precision Editing for S-expressions
if Bundle('guns/vim-sexp', {'f': 'clojure'}) &&
      \ Bundle('tpope/vim-sexp-mappings-for-regular-people', {'f': 'clojure'})
  let g:sexp_filetypes = '' " disable default local mapping
endif

" Extend builtin syntax highlighting to referred and aliased vars
" call Bundles('guns/vim-clojure-highlight')

" Others {{{2

" JSON runtime files
if Bundle('elzr/vim-json', {'f': 'json'})
  augroup bundle_json | autocmd!
    autocmd FileType json setlocal foldmethod=syntax
  augroup END
endif

" JSON manipulation and pretty printing
call Bundle('tpope/vim-jdaddy', {'f': 'json'})
command! -range=% JSONFormat <line1>,<line2>!jq .
command! -range=% JSONFormatEncode <line1>,<line2>!python -m json.tool

" A Vim plugin for Windows PowerShell support
call Bundle('pprovost/vim-ps1', {'f': 'ps1,ps1xml'})

" Syntax file for nginx
call Bundle('vim-scripts/nginx.vim', {'f': 'nginx'})

" ExternalInteraction: {{{1

" Communicate with Nvim through FUSE(user space file system)
if Dundles('fmoralesc/nvimfs')
endif

" An asynchronous execution library
if Bundles('bohrshaw/vimproc.vim:') " 'shougo/vimproc.vim'
  command! -nargs=+ -bang -complete=shellcmd B
        \ if <bang>0 | call vimproc#system_bg(b#vimproc#esc(<q-args>)) |
        \ else | execute 'VimProcBang '.b#vimproc#esc(<q-args>, '/') | endif
  command! -nargs=+ -complete=shellcmd R VimProcRead <args>
endif

" Shells inside Vim
if !has('nvim') && Dundle('shougo/vimshell.vim',
      \ {'m': 'nnoremap <silent>so :<C-u>VimShell<CR>'})
  let g:vimshell_split_command = 'split'
  let g:vimshell_prompt = '% '
  let g:vimshell_secondary_prompt = '> '
  let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
  let g:vimshell_vimshrc_path = expand($MYVIM.'/autoload/vimshrc')
endif

" The interface to Web API
if Bundles('mattn/webapi-vim')
  let g:webapi#system_function = has('win32') ?
        \ 'vimproc#cmd#system' : 'vimproc#system'
endif

" A Git wrapper so awesome, it should be illegal.
if Bundles('Tpope/vim-git') &&
      \ Bundles('tpope/vim-fugitive', 'tpope/vim-rhubarb')
  " Invoke a single git command, mnemonic: '9' resembles the shape of 'g'
  nnoremap <silent>g9 :call git#run()<CR>
  nnoremap <silent><M-g> :call git#run()<CR>
  " Invoke multiple git commands, mnemonic: <Space> is to enter the cmdline
  nnoremap <silent>g<Space> :call git#run(9)<CR>

  nnoremap <expr><M-f>/ ':lcd '.b:git_dir[:-6]."<CR>"
  cnoremap <M-/> <C-r>=v#execute('lcd '.b:git_dir[:-6])<CR>
  nnoremap <expr><M-f>\ ':cd '.b:git_dir[:-6]."<CR>"
  cnoremap <M-\>\ <C-r>=v#execute('cd '.b:git_dir[:-6])<CR>

  " A command :G using vimproc, an alternative to :Git
  execute "command! -nargs=1 -bang -bar -complete=customlist,git#compcmd"
        \ "G execute 'B'.(<bang>0 ? '!' : '') 'git' ".
        \   "(exists('b:git_dir') ? '-C '.b:git_dir[:-6] : '') <q-args>"

  call insert(g:statusline, "%{exists('b:git_dir')?':'.fugitive#head(7):''}")
  augroup bundle_fugitive | autocmd!
    autocmd FileType gitcommit set foldmethod=syntax foldlevel=1
    autocmd FileType git set foldlevel=1
  augroup END

  " It would be `hub` which currently has :Git completion problem.
  " autocmd User Bundle let g:fugitive_git_executable = 'git'

  " Git branch management
  " call Bundles('sodapopcan/vim-twiggy')

  " A git repository viewer(a gitk clone)
  call Bundle('gregsexton/gitv', {'c': 'Gitv'})
endif

" Shows a git diff in the sign column and stages/reverts hunks
if $OSNAME != 'android' && Bundles('airblade/vim-gitgutter')
  nmap [c <Plug>GitGutterPrevHunk
  nmap ]c <Plug>GitGutterNextHunk
  nnoremap <silent>dp :execute &diff ? 'diffput' : 'GitGutterStageHunk'<CR>
  nnoremap <silent>do :execute &diff ? 'diffget' : 'GitGutterRevertHunk'<CR>
  nnoremap dP :GitGutterPreviewHunk<CR>
  nnoremap <silent>c<Leader>s :call gitgutter#signs_toggle()<CR>
  nnoremap <silent>c<Leader>g :call gitgutter#toggle()<CR>
  " let g:gitgutter_enabled = 0

  let g:gitgutter_realtime = 0
  let g:gitgutter_eager = 0
  " Update after a git-commit
  augroup bundle_gitgutter_tmp | augroup bundle_gitgutter | autocmd!
    autocmd BufDelete COMMIT_EDITMSG autocmd bundle_gitgutter_tmp CursorMoved *
          \ GitGutterAll | autocmd! bundle_gitgutter_tmp
  augroup END

  " let g:gitgutter_signs = 0
  let g:gitgutter_sign_removed = '-'
  let g:gitgutter_sign_modified_removed = '='
  " let g:gitgutter_highlight_lines = 1
  " let g:gitgutter_diff_args = '-w'
  let g:gitgutter_map_keys = 0
endif
" Show a VCS diff using Vim's sign column
if Dundles('mhinz/vim-signify')
  " let g:signify_disable_by_default = 1
  let g:signify_vcs_list = ['git']
  let g:signify_sign_delete = '-'
endif

" A git commit browser
call Bundle('junegunn/gv.vim', {'c': 'GV'})

" Browse GitHub events
if Dundles('junegunn/vim-github-dashboard')
  let g:github_dashboard = {'username': 'bohrshaw'}
  nnoremap g<Space>hd :GHDashboard!<CR>
  nnoremap g<Space>ha :GHActivity!<CR>
endif

" Helpers for UNIX(Windows)
if Bundles('Tpope/vim-eunuch')
  nnoremap <silent><M-f>d :Remove<CR>
  nnoremap <silent><M-f>x :execute 'silent below'
        \ buflisted(0) ? 'sbuffer #' : 'sbprevious' \| wincmd p \| Remove<CR>
  nnoremap <silent><M-f>W :W<CR>
  if has('nvim')
    command! -bar W
          \ execute "silent !sudo -vn &>/dev/null" |
          \ if v:shell_error != 0 |
          \   execute "silent !sudo -vS <<<'".inputsecret('[sudo] password: ')."'" |
          \ endif |
          \ SudoWrite
  else
    command! -bar W SudoWrite
  endif
endif

" Tmux basics, insert mode completion of words in adjacent tmux panes
if !has('win32') && Bundles('tpope/vim-tbone') " 'wellle/tmux-complete.vim'
  let g:tmuxcomplete#trigger = '' " completefunc, omnifunc, or empty
endif

" Transparent editing of GPG encrypted files
if Bundle('Jamessan/vim-gnupg', {'f': '*.{gpg,asc,pgp}'})
  autocmd User BundleVim-gnupg doautocmd BufReadCmd

  " For maximum privacy, I'd better edit in a standalone Vim instance with
  " minimum number of bundles.
  command! -nargs=? -complete=command GPG
        \ B! gvim --cmd 'let l=1' -c 'BundleRun vim-gnupg' -c '<args>'

  " Note: 'viminfo' only takes effect when its file is read or written. Thus
  " it's meaningless to empty it temporarily.
  if !g:l
    augroup bundle_gnupg | autocmd!
      autocmd User GnuPG let &viminfo = _viminfo
    augroup END
  endif

  let g:GPGDefaultRecipients = ['Bohr Shaw']

  " For writing encrypted diaries
  command! -nargs=? -complete=file Diary
        \ if !exists("g:loaded_gnupg") |BundleRun vim-gnupg |endif |
        \ edit `=fnamemodify(get(g:, 'DIARY_PATH', ''), ':p').'/'.
        \   (empty(<q-args>) ? strftime('%Y%m%d') : <q-args>).'.gpg'`
  augroup bundle_diary | autocmd!
    autocmd BufNewFile,BufReadPost */diar{y,ies}/*.{gpg,asc,pgp}
        \ setlocal nolinebreak nocursorline spell spelllang=en,cjk
  augroup END
endif

" Translation
if Bundle('bohrshaw/vim-trance', {'m': [
      \ 'nmap d<BS> <Plug>trance',
      \ 'xmap d<BS> <Plug>trance'],
      \ 'c': 'Trance'})
  " let g:trance#default = 'iciba'
  " Translation services
  let g:trance = {
        \ 'youdao': 'key=1387543717&keyfrom=vim-translate',
        \ 'baidu': 'client_id=OjbuMOjZUwHtxcnxblAoQzds',
        \ }
  " let g:trance#youdao_target = 'dict' " 'translate', 'dict' or ''(both)
  " let g:trance#truncate = 0 " truncate long output to be unobtrusive
endif

" URL shortener
call Bundle('bohrshaw/vim-url-shortener', {'c': 'URLShorten'})

" Open a URI with the default browser (or application)
" Alternatives:
" - :call netrw#NetrwBrowseX(...) " or netrw#BrowseX
"   " See: $VIMRUNTIME/plugin/netrwPlugin.vim
" - :py import webbrowser; webbrowser.open()
if Bundles('tyru/open-browser.vim')
  command! -nargs=+ -complete=customlist,openbrowser#_cmd_complete Open
        \ call openbrowser#smart_search(<q-args>)
  NXmap gx <Plug>(openbrowser-smart-search)
  nmap gX <Plug>NetrwBrowseX

  " This will merge into the default one
  let g:openbrowser_search_engines = {
        \ 'google_hk': 'https://google.com.hk/search?q={query}',
        \ 'bing': 'http://global.bing.com/search?q={query}&setmkt=en-us&setlang=en-us',
        \ 'baidu': 'http://www.baidu.com/s?wd={query}',
        \ 'haosou': 'http://www.haosou.com/s?q={query}',
        \ 'translate': 'https://translate.google.com.hk/#auto/zh-CN/{query}',
        \ 'stackoverflow': 'https://stackoverflow.com/search?q={query}',
        \ }
  let g:openbrowser_default_search = 'bing'
  let g:openbrowser_format_message = {'msg': ''} " don't echo messages
  let g:openbrowser_open_vim_command = 'split'

  " Remove unused interfaces
  let g:openbrowser_no_default_menus = 1
  autocmd User Bundle delcommand OpenBrowser |
        \ delcommand OpenBrowserSearch | delcommand OpenBrowserSmartSearch
endif

" Vimscript for gist
if Dundles('mattn/gist-vim', 'mattn/webapi-vim')
  let g:gist_post_private = 1
endif

" Interact with the simplenote service
" call Bundles('mrtazz/simplenote.vim')

" Browse Hacker News inside Vim, :pip install hackernews-python
" command! HackerNews call BundleRun('ryanss/vim-hackernews') |HackerNews

" AlternativeUsages: {{{1

" Personal Wiki for Vim
if Dundles('vimwiki/vimwiki')
  " Restrict vimwiki's operation to only those paths listed in g:vimwiki_list.
  let g:vimwiki_global_ext = 0
  " Don't conceal characters
  let g:vimwiki_conceallevel = 0
  " Register one or more wikis
  let g:vimwiki_list = [{'path': '~/vimwiki/',
        \ 'syntax': 'markdown',
        \ 'ext': '.md'}]
endif

" A calendar application
if Bundle('itchyny/calendar.vim', {'c': 'Calendar'})
  " let g:calendar_google_calendar = 1
  " let g:calendar_google_task = 1
endif

" A convenient interactive calculator inside a buffer
call Bundle('gregsexton/vimcalc', {'c': 'Calc'})

" Task managers
" call Bundles('aaronbieber/quicktask', 'davidoc/taskpaper.vim',
"       \ 'davidoc/todo.txt-vim')

" vim:foldmethod=expr foldexpr=getline(v\:lnum)=~'^\"\ \\a\\+\:\ {'?'>1'\:getline(v\:lnum)=~'^\"\ \\a\\+\ {'?'>2'\:getline(v\:lnum)=~#'\\v^(\ \ )\?(if|fu)'?'a1'\:getline(v\:lnum)=~#'\\v^(\ \ )\?end'?'s1'\:'=':
