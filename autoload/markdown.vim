" Convert markdown to HTML and open it the browser
function! markdown#preview(line1, line2)
  let text = getline(a:line1, a:line2)
  let tmp = has('win32') ? $TEMP.'\' : '/tmp/'
  let [markdown, html] = [tmp.'preview.md', tmp.'preview.html']
  call writefile(text, markdown)
  if !has('win32') && executable('redcarpet')
    call system('redcarpet '.markdown.' >'.html)
  elseif executable('multimarkdown')
    call system('multimarkdown -c '.markdown.' -o '.html)
  else
    echo 'No supported external tools found.'|return 0
  endif
  call v#open(html)
endfunction
