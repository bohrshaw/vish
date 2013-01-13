" This file contains small functions each has an isolated feature.
" If the function will be complex, please move it to autoload directory.

" diff current file with current saved file or a different buffer
command! -nargs=? -complete=buffer DiffWith call DiffWith(<f-args>)
function! DiffWith(...)
  let filetype=&ft
  tab sp " open current buffer in a new tab
  diffthis
  if a:0 == 0
    " load the original file
    vnew | r # | normal! 1Gdd
    " make it temp
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
  else
    exe "vert sb " . a:1
  endif
  diffthis
endfunction

" redir command output to buffer, duplicate with Verbose in scriptease.vim
command! -nargs=1 -complete=command Message call RedirMessages(<q-args>)
function! RedirMessages(cmd)
    " Redirect command outputs to a variable.
    redir => message
    silent execute a:cmd
    redir END
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile
    " Place the messages in the new buffer.
    silent put=message
endfunction

" Set directory-wise configuration.
" Search from the directory the file is located upwards to the root for
" a local configuration file called .lvimrc and sources it.
" The local configuration file is expected to have commands affecting
" only the current buffer.
" au BufNewFile,BufRead * call SetLocalOptions(bufname("%"))
function! SetLocalOptions(fname)
	let dirname = fnamemodify(a:fname, ":p:h")
	while "/" != dirname
		let lvimrc  = dirname . "/.lvimrc"
		if filereadable(lvimrc)
			execute "source " . lvimrc
			break
		endif
		let dirname = fnamemodify(dirname, ":p:h:h")
	endwhile
endfunction

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
command! AppendModeline :call AppendModeline()
function! AppendModeline()
  let modeline = printf(" vim:tw=%d:ts=%d:sw=%d:et:", &textwidth, &shiftwidth, &tabstop)
  let modeline = substitute(&commentstring, "%s", modeline, "")
  " append a new line and a modeline at the end of file
  call append(line("$"), ["", modeline])
endfunction

" vim:tw=78:ts=2:sw=2:et:
