#!/bin/bash

# define variable
usage="$(basename $0) [-h] [-c] [-p] [-P] -- clone or pull git repositories

Where:
    -h  show this help text
    -c  clone repositories
    -p  pull repositories
    -P  pull repositories recursively"

hflag=
cflag=
pflag=
Pflag=
while getopts "hcpP" name
do
    case $name in
    h)    hflag=1;;
    c)    cflag=1;;
    p)    pflag=1;;
    P)    Pflag=1;;
    ?)    printf "Usage: %s: [-a] [-a] [-a] [-a] -- clone or pull git repositories.\n" $0
          exit 2;;
    esac
done

BUNDLE_DIR="$HOME/vimise/vim/bundle"
cd $BUNDLE_DIR

if [ ! -z "$hflag" ]; then
       echo "$usage" >&2
fi

if [ ! -z "$cflag" ]; then
       echo "=========================== Clone Bundles ==========================="
       # Clone bundles specified in bundles.md
       VIMISE_DIR="$HOME/vimise"
       cd $VIMISE_DIR
       # grep lines containing "**chars**", and sed plugin's name, example output: Fugitive
       pluglist="$(grep '\*\*[^\*]*\*\*' $VIMISE_DIR/bundles.md | sed 's/^....\([^:]*\)..:.*$/\1/')"
       for f in $pluglist
       do
           # get the "git clone ..." command
           clone="$(grep $f $VIMISE_DIR/bundles.md | sed 's/.*`\(.*\)`.*$/\1/')"
           # get destination folder name of the "git clone" command
           fold=$(echo $clone | cut -f4 -d' ')
           if [[ ! -d "$fold" ]]; then
               echo  cloning into $fold
               # executing git clone ...
               #eval $clone
           fi
       done
       echo "=========================== Bundles Cloned ==========================="
fi

if [ ! -z "$pflag" ]; then
       echo "=========================== Pull Bundles ==========================="
       # Update all git repositories under current directory,
       # excluding directories end with '~'
       for d in $(ls -d *[^~])
       do
           echo "****************************** $d ******************************"
           (cd $d; git pull)
       done
       echo "=========================== Bundles Pulled ==========================="
fi

if [ ! -z "$Pflag" ]; then
       echo "======================== Pull Bundles Recursively ========================"
       # Update all git repositories under current directory recursively(maxdepth is 3),
       # excluding directories end with '~'
       find . -maxdepth 3 -path '*~' -prune \
            -o -type d -name .git -print | while read f
       do
       echo "****************************** ${f%/.git} ******************************"
           (cd ${f%/.git}; git pull)
       done
       echo "=========================== Bundles Pulled Recursively ==========================="
fi

shift $(($OPTIND - 1))

echo "$usage" >&2
