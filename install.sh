#! /bin/bash
# Install the "VIMISE" distribution.

pushd `dirname $0` > /dev/null
VIM_DIR=`pwd -P`
popd > /dev/null

echo "Starting installation..."

echo "Backing up current vim configuration files..."
today=`date +%Y%m%d`
# Backup old non symbol link files.
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc; do
    [ -e $i ] && [ ! -L $i ] && mv $i $i.$today
done

echo "Linking files..."
ln -sfn $VIM_DIR/vim $HOME/.vim
ln -sf $VIM_DIR/vimrc $HOME/.vimrc
ln -sf $VIM_DIR/gvimrc $HOME/.gvimrc

ln -sf $VIM_DIR/vimrc.core $HOME/.vimrc.core
ln -sf $VIM_DIR/vimrc.light $HOME/.vimrc.light
ln -sf $VIM_DIR/vimrc.bundle $HOME/.vimrc.bundle

echo "Syncing bundles..."
$VIM_DIR/bin/sync-bundle.sh -s

echo "Installation done."
