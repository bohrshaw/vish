#! /bin/bash
# Currently I use Wu Yongwei's pre-compiled vim because it has many languages
# support and the latest patches. This script is from him and is used to update
# vim runtime files(maybe to the develop version).  Modified from here
# "http://wyw.dcweb.cn/download.asp?path=vim&file=update_vimruntime.sh"

# the directory files will be downloaded into
VIMRUNTIME_DL=`echo ~/vimruntime`
# the directory to sync with above directory
VIMRUNTIME_RT="/vagrant/Vim/vim73"

[ -d "$VIMRUNTIME_DL" ] || mkdir -p "$VIMRUNTIME_DL"
cd "$VIMRUNTIME_DL"

# sync from official repository to local directory, skip based on checksum, keep
# partially transfered files
rsync -avzcP --delete-after ftp.nl.vim.org::Vim/runtime/dos/ .

# skip files that are newer on the receiver, and delete extra files from the receiving side
rsync -avu --delete "autoload/" "$VIMRUNTIME_RT/autoload/"
rsync -avu --delete "colors/"   "$VIMRUNTIME_RT/colors/"
rsync -avu --delete "compiler/" "$VIMRUNTIME_RT/compiler/"
rsync -avu --delete "doc/"      "$VIMRUNTIME_RT/doc/"
rsync -avu --delete "ftplugin/" "$VIMRUNTIME_RT/ftplugin/"
rsync -avu --delete "indent/"   "$VIMRUNTIME_RT/indent/"
rsync -avu --delete "keymap/"   "$VIMRUNTIME_RT/keymap/"
rsync -avu          "lang/"     "$VIMRUNTIME_RT/lang/"
rsync -avu --delete "macros/"   "$VIMRUNTIME_RT/macros/"
rsync -avu --delete "plugin/"   "$VIMRUNTIME_RT/plugin/"
#rsync -avu --delete "print/"    "$VIMRUNTIME_RT/print/"
rsync -avu --delete "syntax/"   "$VIMRUNTIME_RT/syntax/"
rsync -avu --delete "tools/"    "$VIMRUNTIME_RT/tools/"
rsync -avu --delete "tutor/"    "$VIMRUNTIME_RT/tutor/"
# preserve modification times
rsync -tvu *.vim "$VIMRUNTIME_RT/"
