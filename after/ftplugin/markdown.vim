" Underline the current line with '='
nnoremap <silent> <leader>ul :copy.\|s/./=/g\|nohls<cr>

" Preview the selected markdown text in the browser {{{1
function! s:MarkdownPreview(line1, line2)
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

command! -range=% MarkdownPreview call s:MarkdownPreview(<line1>, <line2>)

" vim:tw=70 ts=2 sw=2 et fdm=marker:
