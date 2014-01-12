" Underline the current line with '='
nnoremap <silent> <leader>ul :copy.\|s/./=/g\|nohls<cr>

" Preview the selected markdown text in the browser
command! -range=% MarkdownPreview call ftplugin#markdown_preview(<line1>, <line2>)

" vim:tw=70 ts=2 sw=2 et:
