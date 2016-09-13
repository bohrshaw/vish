" Statusline, Tabline, etc.

function! helpline#statusline()
  let m = mode()
  if m ==# 'n' " hide Normal mode as it's normal
    return s:stl
  endif
  " Character[s] indicating the current mode
  let c = m =~# '[VS]' ? m.'L' :
        \ m =~# "[\<C-v>\<C-s>]" ? strtrans(m)[1].'B' :
        \ toupper(m)
  " Mode highlight
  " (Use a User highlight group so that only the current statusline is bold.)
  let hl = c =~# '[VS]' ? 1 : ''
  " To be used in %{} which is evaluated in a dedicated window context
  let g:hl_mode = c.':'
  " The mode is shown in windows holding the current buffer. (only I/R/T)
  " Note: Nvim would have cursor jump due to evaluation of g:actual_curbuf.
  return "%".hl."*%{bufnr('%')!=get(g:,'actual_curbuf')?'':g:hl_mode}".s:stl
endfunction
let s:stl1 = "%1*%w%q" " preview, quickfix
let s:stl1 .= "%n" " buffer number
let s:stl1 .= "%<" " at this point to truncate
" g:statusline would be inserted here.
let s:stl2 = ":%{&filetype}" " file type
let s:stl2 .= "%{(&fenc!='utf-8'&&&fenc!='')?':'.&fenc:''}" " file encoding
let s:stl2 .= "%{&ff!='unix'?':'.&ff:''}" " file format
let s:stl2 .= ":%*%.30f" " file path
let s:stl2 .= "%1*%m%{(&modifiable?'':'-').(&readonly?'=':'')}"
let s:stl2 .= "%{get(b:,'case_reverse',0)?':CAPS':''}" " software caps lock
let s:stl2 .= "%*%=" " left/right separator
" Note this isn't correct when two windows holding the same buffer have
" different CWDs, which I think doesn't worth fixing.
" let s:stl2 .= "%1*%{bufnr('%')==get(g:,'actual_curbuf')?".
"       \"pathshorten(fnamemodify(getcwd(),':~')). (haslocaldir()?':L':''):''}"
let s:stl2 .= "%*:%l/%L:%P" " cursor position, line percentage
" The array g:statusline contains flags inserted by bundles
execute has('vim_starting') ? 'autocmd User Vimrc' : ''
        \ "let s:stl = s:stl1.join(get(g:, 'statusline', []), '').s:stl2"

function! helpline#tabline()
  let l = '%#StatusLineNC#'.s:prefix.':'
  for i in range(1, tabpagenr('$'))
    let l .= (i == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#').'%'.i.'T'.
          \ ' %{helpline#tablabel('.i.')} '
  endfor
  let l .= '%#TabLineFill#%T%=%#TabLine#%999X'
  let l .= '%{strftime("%a %m/%d/%Y %H:%M:%S")}' " useful in full screen
  return l
endfunction
function! helpline#tablabel(t)
  return a:t.':'.join(
        \ map(range(1, tabpagewinnr(a:t, '$')),
        \   "pathshorten(fnamemodify(getcwd(v:val, a:t),':~'))"),
        \ ':')
endfunction

let s:prefix =
      \ (has('nvim') ? toupper(v:progname) : '%{v:servername}').
      \ (g:l ? '[L]' : '').
      \ (empty($SSH_TTY) ? '' : '@'.hostname()).
      \ ":%{fnamemodify(v:this_session, ':t:r')}"
