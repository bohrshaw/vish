function! b#unimpaired#move(cmd, count) abort
  normal! m`
  execute 'set foldmethod=manual|'.
        \(a:cmd =~ '[<>]'?"'<,'>":'').'move'.a:cmd.a:count.
        \'|set foldmethod='.&foldmethod
  normal! ``
  silent! call repeat#set(a:cmd =~ '+' ? ']e' : '[e', a:count)
endfunction
