#!/bin/ash
# make a vimise extension(just customisation and plugins) for tiny core linux.
# advantages: this ext. can be copyed to RAM to increase editing speed.
# the final stable extension should not include temp or git related files, and I should also consider remove some supporting files
#
# making an extension in tcl is just one methods of backup options, further more I may consider remastering tcl to include this ext. into os core.

echo "preparing..."
tcedir="/mnt/sda6/tce/optional"
extdir="$HOME/exts/vimise"
vimisedir="$HOME/exts/vimise/home/tc/vimise"
# delete old files
if [ -d $extdir ]; then
    rm -rf $extdir
fi
mkdir -p $HOME/exts/vimise/home/tc

echo "loading squashfs-tools-4.x.tcz"
tce-load -i $tcedir/squashfs-tools-4.x.tcz

echo "preparing files..."
cp -r $HOME/vimise $extdir/home/tc
cp -ax $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimperator $HOME/.vimperatorrc $extdir/home/tc
rm -rf $vimisedir/vim/tmp
rm -rf $vimisedir/vimperator/info

echo "making squashfs..."
mksquashfs $HOME/exts/vimise/ $tcedir/vimise.tcz -noappend

echo "cleaning up..."
rm -rf $extdir

echo "done!"

