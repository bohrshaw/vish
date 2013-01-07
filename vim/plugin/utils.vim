" This file contains small functions each has an isolated feature.
" If the function will be complex, please move it to autoload directory.

" diff current file with current saved file or a different buffer
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
com! -nargs=? -complete=buffer DiffWith call DiffWith(<f-args>)

" redir command output to buffer, duplicate with Verbose in scriptease.vim
function! RedirMessages(msgcmd, destcmd)
    " Redirect messages to a variable.
    redir => message
    " Execute the specified Ex command
    silent execute a:msgcmd
    redir END

    " If no command is provided, output will be placed in the current buffer.
    if strlen(a:destcmd) " destcmd is not an empty string
        silent execute a:destcmd
    endif

    " Place the messages in the destination buffer.
    silent put=message " a variable is also a expression
endfunction
" examples   :TabMessage echo "Key mappings for Control+A:" | map <C-A>
command! -nargs=+ -complete=command BufMessage call RedirMessages(<q-args>, ''       )
command! -nargs=+ -complete=command WinMessage call RedirMessages(<q-args>, 'new'    )
command! -nargs=+ -complete=command TabMessage call RedirMessages(<q-args>, 'tabnew' )

" Set directory-wise configuration.
" Search from the directory the file is located upwards to the root for
" a local configuration file called .lvimrc and sources it.
" The local configuration file is expected to have commands affecting
" only the current buffer.
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
" au BufNewFile,BufRead * call SetLocalOptions(bufname("%"))

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
  let l:modeline = printf(" vim:et:ts=%d:sw=%d:tw=%d:fdm=marker:", &tabstop, &shiftwidth, &textwidth)
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  # append a new line and a modeline at the end of file
  call append(line("$"), ["", l:modeline])
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" vim: nowrap fdm=syntax
