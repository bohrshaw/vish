" Encrypt or decrypt a file. You must provide the indented password, otherwise
" the behavior is unpredictable.
function! misc#mystify()
  call inputsave()
  let p = inputsecret('Password: ')
  call inputrestore()
  let a = nr2char(char2nr(p[0])-15)
  let b = nr2char(char2nr(p[1])+14)
  let c = nr2char(char2nr(p[2])-11)
  let d = p[3]
  let e = p[4]
  let f = p[5]
  let g = nr2char(char2nr(p[6])+16)
  let h = p[7]
  let i = p[8]
  let j = nr2char(char2nr(p[6])+79)
  let k = nr2char(char2nr(p[6])-10)
  execute 'silent normal! '.h.h.k.h.b.a.g.d.f.b.f.f.k.i.e.a.j.h.f.c.e.i
endfunction
