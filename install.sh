#!/bin/bash
# Install the "VIMISE" distribution.

pushd `dirname $0` > /dev/null
VIM_DIR=`pwd -P`
popd > /dev/null

echo "Start installation ..."

echo "Back up files ..."
today=`date +%Y%m%d`

# Backup old non symbol link files.
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc; do
    [ -e $i ] && [ ! -L $i ] && mv $i $i.$today
done

echo "Link files ..."
ln -sfn $VIM_DIR $HOME/.vim
ln -sf $VIM_DIR/vimrc $HOME/.vimrc
ln -sf $VIM_DIR/vimrc.light $HOME/.vimrc.light

echo "Clone bundles ..."
$VIM_DIR/bin/bundle.rb

echo "Generate help tags ..."
vim +Helptags +qall

echo "Installation done."
