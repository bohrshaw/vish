" Create mappings for executing Viml
function! ftplugin#vim_map()
  nnoremap <buffer><silent> R mz:set operatorfunc=vimrc#run<CR>g@
  " use :normal to support mapping count
  nmap <buffer><silent> Rr :normal RVl<CR>
  nnoremap <buffer><expr> RR ':'.(g:loaded_scriptease?'Runtime':'source %').'<CR>'
  xnoremap <buffer><silent> R mz:<C-U>call vimrc#run(visualmode())<CR>
endfunction

" Goto a position specified with a pattern 'count' times.
function! ftplugin#help_goto(pattern, ...)
    let counter = v:count1
    let flag = a:0 == 0 ? '' : a:1
    while counter > 0
        " search without affecting search history
        silent call search(a:pattern, flag)
        let counter = counter - 1
    endwhile
endfunction
