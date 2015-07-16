" Return a directory list based on a glob pattern.
function! path#glob_directories(pattern) abort
  return filter(split(glob(a:pattern),"\n"), 'isdirectory(v:val)')
endfunction
