" Fold lines other than the picked range
function! fold#pick(...)
  let [line1, line2] = a:0 == 1 ? ["'[", "']"] : ["'<", "'>"]
  let b:fold_opts = [&fdm, &fdl, &fde]
  set fde=0 fdm=expr | redraw " disable existing folding
  set fdm=manual
  execute '1,'.line1.'-1fold|'.line2.'+1,$'.'fold'
endfunction

" Restore the previous folding layout
function! fold#restore()
  normal! zE
  let [&fdm, &fdl, &fde] = b:fold_opts
  normal! zvzz
endfunction

" Edit a range of lines in a separate buffer
function! fold#part(...) range
  let [line1, line2] = !empty(get(a:, 1, '')) ?
        \ [line("'["), line("']")] : [a:firstline, a:lastline]
  let b:lines_part = {'line1': line1, 'line2': line2}
  let bufnr = bufnr('')

  execute 'edit' bufname('').'.part'
        \ '| set filetype='.(empty(get(a:, 2, '')) ? &filetype : a:2)
  set buftype=acwrite
  autocmd BufWriteCmd <buffer> call fold#join()
  let b:bufnr_comp = bufnr

  setlocal undolevels=-1
  call setline(1, getbufline(bufnr, line1, line2))
  setlocal undolevels& nomodified
endfunction

" Replace marked lines in the complete buffer with the current buffer
function! fold#join()
  if !exists('b:bufnr_comp') | return | endif
  let bufnr = bufnr('')

  let bufwinnr_comp = bufwinnr(b:bufnr_comp)
  execute bufwinnr_comp < 0 ? 'buffer '.b:bufnr_comp : bufwinnr_comp.'wincmd w'

  execute b:lines_part.line1.','.b:lines_part.line2.'delete'
  undojoin
  call append(b:lines_part.line1 - 1, getbufline(bufnr, 0, '$'))
  normal! '[

  execute 'bwipeout!' bufnr
endfunction
