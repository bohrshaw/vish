" After init and bundle files are loaded
if exists('#User#Init')
  doautocmd User Init
endif
if exists('#User#Bundle')
  doautocmd User Bundle
endif
