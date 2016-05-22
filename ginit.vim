" Neovim-qt GUI settings

if !exists('g:GuiLoaded')
  echomsg 'The plugin "neovim_gui_shim" is not loaded.'
  finish
endif

GuiFont Consolas:h09
call GuiWindowMaximized(1)
color seoul256
