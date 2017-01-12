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
let s:stl1 .= "%*%m" " modified or non-modifiable
let s:stl1 .= "%<" " at this point to truncate
let s:stl1 .= "%1*%{(&readonly?'=':'')}"
let s:stl1 .= ":%{&filetype}" " file type
let s:stl1 .= "%{(&fenc!='utf-8'&&&fenc!='')?':'.&fenc:''}" " file encoding
let s:stl1 .= "%{&ff!='unix'?':'.&ff:''}" " file format
let s:stl1 .= ":%*%.30f%1*" " file path
" g:statusline would be inserted here.
let s:stl2 = "%{get (b:,'case_reverse',0)?':CAPS':''}" " software caps lock
let s:stl2 .= "%*%=" " left/right separator
" Note this isn't correct when two windows holding the same buffer have
" different CWDs, which I think doesn't worth fixing.
let s:stl2 .= "%1*%{bufnr('%')==get(g:,'actual_curbuf')?".
      \"pathshorten(fnamemodify(getcwd(),':~')). (haslocaldir()?':L':''):''}"
let s:stl2 .= "%*:%c%V:%l/%L:%P" " cursor position, line percentage
" The array g:statusline contains flags inserted by bundles
execute has('vim_starting') ? 'autocmd User Init' : ''
        \ "let s:stl = s:stl1.':'.join(values(g:statusline), ':').s:stl2"

function! helpline#tabline()
  let tabpagenrs = tabpagenr('$')
  let l = '%#StatusLineNC#'.s:prefix.': %<'
  for i in range(1, tabpagenrs)
    let l .= (i == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#').'%'.i.'T'.
          \ ' %{helpline#tablabel('.i.')} '
  endfor
  let l .= '%#StatusLineNC# :'.s:tabline
  let l .= '%#TabLineFill#%T%=%#TabLine#%999X'
  " Time info is especially useful in full screen
  let l .= '%{strftime('.
        \string(tabpagenrs < 4 ? "%a %m/%d/%Y %H:%M:%S" : "%H:%M").
        \')}'
  return l
endfunction
" Return the "context" of a tabpage
function! helpline#tablabel(t) " t is the tabpage number
  let bufs = []
  for b in tabpagebuflist(a:t)
    if getbufvar(b, '&buftype') == ''
      call add(bufs, strpart(fnamemodify(bufname(b), ':t'), 0, 15))
    endif
  endfor
  return a:t.':'.join(bufs, ',')
endfunction
execute has('vim_starting') ? 'autocmd User Init' : ''
        \ "let s:tabline = join(values(g:tabline), ':')"

let s:prefix =
      \ (has('nvim') ? toupper(v:progname) : '%{v:servername}').
      \ (g:l ? '[L]' : '').
      \ (empty($SSH_TTY) ? '' : '@'.hostname()).
      \ ":%{fnamemodify(v:this_session, ':t:r')}"
