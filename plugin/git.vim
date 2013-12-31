" Disable modeline parsing in gitcommit files.
au BufNewFile,BufReadPre COMMIT_EDITMSG setlocal modeline! spell
