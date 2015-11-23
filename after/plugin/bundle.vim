" Config after vimrc or (built-in) bundles are loaded
if exists('#User#Vimrc')
  doautocmd User Vimrc
endif

" Config after bundles are loaded
if exists('#User#Bundle')
  doautocmd User Bundle
endif
