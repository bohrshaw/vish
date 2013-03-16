REM Start installation...
@if not exist "%HOME%" @set HOME=%HOMEDRIVE%%HOMEPATH%
@if not exist "%HOME%" @set HOME=%USERPROFILE%

REM Set path variables.
@if not exist "%HOME%\vimise" call mklink /J "%HOME%\vimise" "D:\projects\vimise"
@set VIMISE_DIR=%HOME%\vimise
@set GIT_DIR=C:\Program Files\Git
@set SYNC_DIR=D:\Sync\SkyDrive\Documents

REM Make links.
@if not exist "%HOME%\.vim" call mklink /J "%HOME%\.vim" "%VIMISE_DIR%\vim"
@if not exist "%HOME%\.vimrc" call mklink "%HOME%\.vimrc" "%VIMISE_DIR%\vimrc"
@if not exist "%HOME%\.gvimrc" call mklink "%HOME%\.gvimrc" "%VIMISE_DIR%\gvimrc"
@if not exist "%HOME%\vimperator" call mklink /J "%HOME%\vimperator" "%VIMISE_DIR%\vimperator"
@if not exist "%HOME%\.vimperatorrc" call mklink "%HOME%\.vimperatorrc" "%VIMISE_DIR%\vimperatorrc"

REM Make sure bash is ready.
@if not exist "%GIT_DIR%\cmd\bash.cmd" call copy "%VIMISE_DIR%\bin\bash.cmd" "%GIT_DIR%\cmd\bash.cmd"

REM Sync bundles.
"%GIT_DIR%\cmd\bash.cmd" %VIMISE_DIR%\bin\git.sh -s

REM Link the vimwiki repository to the synced directory.
@if not exist "%HOME%\vimwiki" call mklink /J "%HOME%\vimwiki" "%SYNC_DIR%\VimWiki"

REM Finish installation.
