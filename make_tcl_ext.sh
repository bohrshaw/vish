#!/bin/ash
# make a vimise extension(just customisation and plugins) for tiny core linux.
# advantages: this ext. can be copyed to RAM to increase editing speed.
# the final stable extension should not include temp or git related files, and I should also consider remove some supporting files
#
# making an extension in tcl is just one methods of backup options, further more I may consider remastering tcl to include this ext. into os core.

echo "check and delete old files"
if [ -d ~/exts/vimise ]; then
    rm -rf ~/exts/vimise
fi

echo "preparing..."
tcedir="/mnt/sda6/tce/optional"
mkdir -p $HOME/exts/vimise/home/tc
extdir="$HOME/exts/vimise"
vimisedir="$HOME/exts/vimise/home/tc/vimise"

echo "loading squashfs-tools-4.x.tcz"
tce-load -i $tcedir/squashfs-tools-4.x.tcz

echo "preparing files..."
cd $HOME
cp -r vimise $extdir/home/tc
cp -ax .vim .vimrc .gvimrc .vimperator .vimperatorrc $extdir/home/tc
rm -rf $vimisedir/vim/tmp
rm -rf $vimisedir/vimperator/info

echo "making squashfs..."
cd $HOME/exts
mksquashfs vimise/ $tcedir/vimise.tcz

echo "cleaning up..."
rm -rf $extdir

echo "done!"

