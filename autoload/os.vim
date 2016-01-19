" Create a path (also see the implementation in "vim-eunuch")
function! os#mkdir(...)
  let dir = fnamemodify(expand(a:0 || empty(a:1) ? '%:h' : a:1), ':p')
  try
    call mkdir(dir, 'p')
    echo "Succeed in creating directory: " . dir
  catch
    echohl WarningMsg | echo "Fail in creating directory: " . dir | echohl NONE
  endtry
endfunction

" Open a file with the default system program
function! os#open(...)
  if has('unix')
    call system("xdg-open ".a:1)
  elseif has('win32')
    call system('"'.a:1.'"')
  elseif has('mac')
    call system('open '.a:1)
  endif
endfunction
