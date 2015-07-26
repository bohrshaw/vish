" Return a directory list based on a glob pattern.
function! path#glob_directories(pattern) abort
  return filter(split(glob(a:pattern),"\n"), 'isdirectory(v:val)')
endfunction

" Return the platform specific path separator
" \ on Windows unless shellslash is set, / everywhere else.
function! path#slash() abort
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction
