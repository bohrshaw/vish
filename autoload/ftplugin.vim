" Goto a position specified with a pattern 'count' times.
function! ftplugin#help_goto(pattern, ...)
    let counter = v:count1
    let flag = a:0 == 0 ? '' : a:1
    while counter > 0
        " search without affecting search history
        silent call search(a:pattern, flag)
        let counter = counter - 1
    endwhile
endfunction

" Preview the selected markdown text in the browser
function! ftplugin#markdown_preview(line1, line2)
  let text = getline(a:line1, a:line2)
  let md_file = "markdown-preview.md"
  let html_file = "markdown-preview.html"
  " Set the path of temporary files
  if has('win32')
    let md_path = $temp . "\\" . md_file
    let html_path = $temp . "\\" . html_file
  else
    let md_path = "/tmp/" . md_file
    let html_path = "/tmp/" . html_file
  endif
  " Create the markdown file
  call writefile(text, md_path)
  " Generate the HTML file
  call system("multimarkdown -c " . md_path . " -o " . html_path)
  " Open the HTML file in the browser
  if has('win32')
    call system('"' . html_path . '"')
  elseif has('unix')
    call system("xdg-open " . html_path)
  elseif has('mac')
    call system("open " . html_path)
  endif
endfunction
