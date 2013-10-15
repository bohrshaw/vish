#!/usr/bin/env bash
# Uninstall the "VIMISE" distribution.

echo "Starting uninstallation..."

pushd $HOME

echo "Remove files..."
rm -rf .vim .vimrc .vimrc.light

echo "Restore backups..."
for i in .vim .vimrc*; do
    j=`echo $i | sed -r 's/\.[0-9]+$//g'`
    mv $i $j 2>/dev/null
done

popd

echo "Uninstallation done."
