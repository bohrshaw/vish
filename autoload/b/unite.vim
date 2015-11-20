function! b#unite#map()
  " Navigation
  " Note <Esc> is mapped to <Plug>(unite_insert_leave) which just moves the curosr
  imap <buffer><M-x> <Esc>x
  imap <buffer><M-j> <Plug>(unite_select_next_line)
  imap <buffer><M-k> <Plug>(unite_select_previous_line)
  " Action
  inoremap <silent><buffer><expr><M-w>s unite#do_action('split')
  inoremap <silent><buffer><expr><M-w>v unite#do_action('vsplit')
  inoremap <silent><buffer><expr><M-w>t unite#do_action('tabopen')
  inoremap <silent><buffer><expr><M-e> unite#do_action('edit')
  " Mark
  unmap <buffer><Space>|unmap <buffer><S-Space>
  nmap <buffer>m <Plug>(unite_toggle_mark_current_candidate)
  nmap <buffer>M <Plug>(unite_toggle_mark_current_candidate_up)
  xmap <buffer>m v_<Plug>(unite_toggle_mark_selected_candidates)
  unmap! <buffer><Space>|unmap! <buffer><S-Space>
  imap <expr><buffer>m unite#smart_map('m', "\<Plug>(unite_toggle_mark_current_candidate)")
  imap <expr><buffer>M unite#smart_map('M', "\<Plug>(unite_toggle_mark_current_candidate_up)")
  " Quit
  imap <buffer><M-q> <Plug>(unite_exit)
  nmap <buffer><M-q> <Plug>(unite_exit)
  imap <buffer><M-Q> <Esc><Plug>(unite_all_exit)
  nmap <buffer>R <Plug>(unite_restart)
  " Others
  nmap <buffer>C <Plug>(unite_disable_max_candidates)
  imap <buffer><M-Space> <Esc>:
endfunction

function! b#unite#files_project()
  let git_dir = get(b:, 'git_dir', fugitive#extract_git_dir(getcwd()))
  if !empty(git_dir)
    execute 'lcd '.git_dir[:-6]
    Unite file_rec/git:--cached:--others:--exclude-standard
  else
    execute 'Unite file_rec/'.(has('nvim')?'neovim':'async')
  endif
endfunction
