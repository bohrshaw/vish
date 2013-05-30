#! /bin/bash
# Uninstall the "VIMISE" distribution.

echo "Starting uninstallation ..."

cd $HOME

echo "Unlink files ..."
rm .vim .vimrc .gvimrc .vimrc.core .vimrc.light .vimrc.bundle

echo "Recover files ..."
for i in .vim.* .vimrc.* .gvimrc.*; do
    j=`echo $i | sed -r 's/\.[0-9]+$//g'`
    mv $i $j 2>/dev/null
done

echo "Uninstallation done."
