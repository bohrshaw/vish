@if not exist "%HOME%" @set HOME=%HOMEDRIVE%%HOMEPATH%
@if not exist "%HOME%" @set HOME=%USERPROFILE%

@set CUSE_DIR=D:\projects\configent\vimperator
call mklink /J %HOME%\vimperator %CUSE_DIR%
call mklink %HOME%\.vimperatorrc %CUSE_DIR%\vimperatorrc.link
