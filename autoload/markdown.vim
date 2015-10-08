" Convert markdown to HTML and open it the browser
" Note:
" This implementation is Windows only. On other platforms, the bundle
" 'vim-preview' works well.
" Use :QuickRun to preview the HTML inside Vim.
function! markdown#preview(line1, line2)
  let tmp = has('win32') ? $TEMP.'\' : '/tmp/'
  if &modified
    let markdown = tmp.'preview.md'
    let text = getline(a:line1, a:line2)
    call writefile(text, markdown)
  else
    let markdown = expand('%:p')
  endif
  let html = tmp.'preview.md.html'

  if executable('pandoc')
    call system('pandoc -sf markdown_github -o '.html.' '.markdown)
  elseif executable('cmark')
    set noshelltemp " faster but 'fileencoding' won't be detected
    call writefile(systemlist('cmark '.markdown), html)
    set shelltemp
  elseif executable('redcarpet')
    set noshelltemp
    call writefile(systemlist('redcarpet '.markdown), html)
    set shelltemp
  elseif executable('blackfriday-tool')
    call system('blackfriday-tool '.markdown.' '.html)
  elseif executable('multimarkdown')
    call system('multimarkdown -c '.markdown.' -o '.html)
  else
    echo 'No supported external markdown tools found.'
    return -1
  endif
  call v#open(html)
endfunction
