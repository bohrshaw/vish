REM Reference: http://vim.wikia.com/wiki/Launch_files_in_new_tabs_under_Windows

REM Double click an associated file to open it in an existing vim instance in a new tab.
ftype txtfile="D:\ProgramsPortable\Vim\vim74\gvim.exe" --servername GVIM --remote-tab-silent "%%1"

REM You can create or modify a file type group before setup file association.
REM assoc .c=code
REM assoc .h=code
REM ftype code="D:\ProgramsPortable\Vim\vim74\gvim.exe" --remote-tab-silent "%%1"

REM vim:cms=REM\ %s:
