" Modified from http://www.vim.org/scripts/script.php?script_id=616

" Splits the window and creates a table of Ascii values and characters.  The
" values can be displayed as decimal, octal, or hexadecimal.  The control
" characters are displayed as ^[letter] since outputing ^M, ^I, and the like
" will get interpreted as <CR>, <tab>, etc.
function! ascii#print(...)
   if ( a:0 == 0 )
      let base = 10
   elseif ( a:1 == 10 ) || ( a:1 == 8 ) || ( a:1 == 16 )
      let base = a:1
   else
      let base = 10
   endif
   let n = 0
   let titletext = "ASCII Table Base " . base
   let outbuf = "===================== "
   let outbuf = outbuf . titletext
   let outbuf = outbuf . " =====================\n"
   let outbuf = outbuf . "val chr |val chr|val chr|val chr|val chr|val chr|val chr|val chr\n"
   let outbuf = outbuf . "--------+-------+-------+-------+-------+-------+-------+-------\n"
   let r = 0
   while r <= 31
      let c = 0
      while c <= 7
         let n = r + ( c * 32 )
        if ( base == 16 )
           let spacing = "0x"
           if ( n < 16 )
              let spacing = spacing . "0"
           endif
         elseif ( base == 8 )
            let spacing = " "
            if ( n < 8 )
               let spacing = spacing . "00"
            elseif ( n < 64 )
               let spacing = spacing . "0"
            endif
        elseif ( n < 10 )
          let spacing = "   "
        elseif ( n < 100 )
          let spacing = "  "
        else
          let spacing = " "
        endif
        let outbuf = outbuf . spacing . s:Nr2Base(n, base)
        if ( n == 0 )
          let outbuf = outbuf . " NL"
        elseif ( n >= 1 && n <= 26 )
          " Some control characters don't play well with terminals, so fake it
          let outbuf = outbuf . " ^" . nr2char(n+64)
        else
          let outbuf = outbuf . " " . nr2char(n)
        endif
        let c = c + 1
        let outbuf = outbuf . ( ( c == 8 ) ? "" : " |" )
     endwhile
     let r = r + 1
     let outbuf = outbuf . "\n"
   endwhile

   "put =outbuf
   "echo outbuf
   call s:BldWindow(outbuf)
endfunction

" The function Nr2Base() returns the string of a decimal number in a given
" base up to base 16.
" Based on vim documentation Nr2Hex.
function! s:Nr2Base(nr, nbase)
  if ( a:nbase > 16 ) || ( a:nbase < 2 )
     return ""
  endif
  let n = a:nr
  let r = ( n == 0 ? "0" : "" )
  while n
    let r = '0123456789ABCDEF'[n % a:nbase] . r
    let n = n / a:nbase
  endwhile
  return r
endfunc

" Split the window or use the existing split to display the table.
" Based on calendar.vim from Yasuhiro Matsumoto
function! s:BldWindow(disptext)
  " make window
  let vheight = 19
  let vwinnum=bufnr('__ASCIITable')
  if getbufvar(vwinnum, 'ASCIITable')=='ASCIITable'
    let vwinnum=bufwinnr(vwinnum)
  else
    let vwinnum=-1
  endif

  if vwinnum >= 0
    " if already exist
    if vwinnum != bufwinnr('%')
      exe "normal \<c-w>".vwinnum."w"
    endif
    setlocal modifiable
    silent %d _
  else
    execute vheight.'split __ASCIITable'

    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=wipe
    setlocal nowrap
    setlocal norightleft
    setlocal foldcolumn=0
    setlocal modifiable
    nnoremap <buffer><silent><LocalLeader>d :call ascii#print(10)<CR>
    nnoremap <buffer><silent><LocalLeader>o :call ascii#print(8)<CR>
    nnoremap <buffer><silent><LocalLeader>x :call ascii#print(16)<CR>
    nnoremap <buffer><silent>q :bwipeout<CR>
    let b:ASCIITable='ASCIITable'
  endif

  silent put! =a:disptext
endfunc
