@if not exist "%HOME%" @set HOME=%HOMEDRIVE%%HOMEPATH%
@if not exist "%HOME%" @set HOME=%USERPROFILE%

call mklink /J %HOME%\vimise D:\projects\vimise
@set BASE_DIR=%HOME%\vimise
:: call git clone --recursive -b 3.0 git://github.com/spf13/spf13-vim.git %BASE_DIR%
:: call mkdir %BASE_DIR%\vim\bundle
call mklink /J %HOME%\.vim %BASE_DIR%\vim
call mklink %HOME%\.vimrc %BASE_DIR%\vimrc
call mklink %HOME%\.gvimrc %BASE_DIR%\gvimrc

call mklink /J %HOME%\vimperator %BASE_DIR%\vimperator
call mklink %HOME%\.vimperatorrc %BASE_DIR%\vimperatorrc

:: call git clone http://github.com/gmarik/vundle.git %HOME%/.vim/bundle/vundle
:: call vim -u "$BASE_DIR/vimrc" - +BundleInstall!
