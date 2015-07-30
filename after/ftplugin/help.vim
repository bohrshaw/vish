" After $VIMRUNTIME\ftplugin\vim.vim
if exists("b:undo_ftplugin")
  " Show hidden characters, useful for copying text
  set conceallevel=0
  " Avoid re-sourcing ftplugin files when b:did_ftplugin && !b:undo_ftplugin
  unlet b:undo_ftplugin
endif
