#!/usr/bin/env bash
# Uninstall the "Vish" distribution.

echo "Starting uninstallation..."

pushd $HOME

echo "Remove files..."
rm -rf .vim .vimrc .gvimrc

echo "Restore backups..."
for i in .vim .vimrc* .gvimrc; do
    j=`echo $i | sed -r 's/\.[0-9]+$//g'`
    mv $i $j 2>/dev/null
done

popd

echo "Uninstallation done."
