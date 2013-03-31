#! /bin/bash
# Install the "VIMISE" distribution including vim and vimperator.

# Link the repository to $HOME, so you can put this repository anywhere.
if [ ! -d $HOME/vimise ]; then
    ln -sfn $PWD $HOME
fi
VIMISE_PATH="$HOME/vimise"
cd $VIMISE_PATH

echo "Starting installation..."

echo "Backing up current vim configuration files..."
today=`date +%Y%m%d`
# Backup old non symbol link files.
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimperator $HOME/.vimperatorrc; do
    [ -e $i ] && [ ! -L $i ] && mv $i $i.$today
done

echo "Linking files..."
ln -sfn $VIMISE_PATH/vim $HOME/.vim
ln -sf $VIMISE_PATH/vimrc.core $HOME/.vimrc.core
ln -sf $VIMISE_PATH/vimrc $HOME/.vimrc
ln -sf $VIMISE_PATH/vimrc.light $HOME/.vimrc.light
ln -sf $VIMISE_PATH/gvimrc $HOME/.gvimrc

echo "Syncing bundles..."
bin/sync-bundle.sh -s

echo "Finish installation."
