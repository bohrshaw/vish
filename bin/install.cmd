REM Start installation...
@if not exist "%HOME%" @set HOME=%HOMEDRIVE%%HOMEPATH%
@if not exist "%HOME%" @set HOME=%USERPROFILE%

REM Set path variables.
@set VIM_DIR=%HOME%\configent\vim
@set GIT_DIR=D:\ProgramsPortable\SmartGitHg\git
@set SYNC_DIR=D:\Sync\SkyDrive\Documents

REM Make links.
@if not exist "%HOME%\.vim" call mklink /D "%HOME%\.vim" "%VIM_DIR%\vim"
@if not exist "%HOME%\.vimrc" call mklink "%HOME%\.vimrc" "%VIM_DIR%\vimrc"
@if not exist "%HOME%\_vimrc" call mklink "%HOME%\.vimrc" "%VIM_DIR%\vimrc"
@if not exist "%HOME%\.gvimrc" call mklink "%HOME%\.gvimrc" "%VIM_DIR%\gvimrc"
@if not exist "%HOME%\vimperator" call mklink /D "%HOME%\vimperator" "%VIM_DIR%\vimperator"
@if not exist "%HOME%\.vimperatorrc" call mklink "%HOME%\.vimperatorrc" "%VIM_DIR%\vimperatorrc"

REM Make sure bash is ready.
@if not exist "%GIT_DIR%\cmd\bash.cmd" call copy "%VIM_DIR%\bin\bash.cmd" "%GIT_DIR%\cmd\bash.cmd"

REM Sync bundles.
"%GIT_DIR%\cmd\bash.cmd" %VIM_DIR%\bin\git.sh -s

REM Link the vimwiki repository to the synced directory.
@if not exist "%HOME%\vimwiki" call mklink /J "%HOME%\vimwiki" "%SYNC_DIR%\VimWiki"

REM Finish installation.
