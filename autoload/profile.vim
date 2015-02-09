" Generate a table from the file produced by :profile
function! profile#tabular()
  " Append a line which happens to be a table header to EOF, as the cursor
  " need a consistent place to sit on in :global processing.
  $put ='TotalTime SelfTime Times Script'

  " SCRIPT  /c/Users/Bohr/.vimrc
  " Sourced 1 time
  " Total time:   0.236904
  "  Self time:   0.090869
  " |
  " V
  " SCRIPT  /c/Users/Bohr/.vimrc
  " 0.236904 0.090869
  " Sourced 1 time
  " |
  " V
  " 0.236904 0.090869 1
  " SCRIPT  /c/Users/Bohr/.vimrc
  g/^SCRIPT/+4,/\v^SCRIPT|%$/-d|
        \ -2,-1s/\v.{-}\ze\d//|-j|m-2|
        \ s/\v\n.*(\d+).*/ \1/|m-2|
        \ s/\nSCRIPT\s*/ /
  sort!
endfunction
