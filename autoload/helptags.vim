" Invoked by `vundle`
function! helptags#(overwrite)
  call rtp#inject()
  execute 'Helptags'.(a:overwrite ? '!' : '')
endfunction
