#!/bin/bash

# define variable
usage="$(basename $0) [-h] [-d directory] [-c repository] [-C] [-p] [-P] -- clone or pull git repositories

Where:
    -h  show this help text
    -d  change directory, default is '$HOME/.vim/bundle'
    -c  clone a repository, either specify the full url or just like 'tpope/vim-pathogen'
    -C  clone all repositories specified in bundles.md
    -p  pull repositories under the 'bundle' directory
    -P  pull repositories recursively under the 'bundle' directory"

hflag=
dflag=
cflag=
Cflag=
pflag=
Pflag=
while getopts "hd:c:CpP" name
do
    case $name in
    h)    hflag=1;;
    d)    dflag=1
          dval="$OPTARG";;
    c)    cflag=1
          cval="$OPTARG";;
    C)    Cflag=1;;
    p)    pflag=1;;
    P)    Pflag=1;;
    ?)    printf "Usage: %s: [-h] [-c args] [-C] [-p] [-P] -- clone or pull git repositories.\n" $0
          exit 2;;
    esac
done

if [ ! -z "$hflag" ] || [ $# -eq 0 ]; then
       echo "$usage" >&2
fi

if [ ! -z "$dflag" ]; then
  BUNDLE_DIR="$dval"
else
  BUNDLE_DIR="$HOME/.vim/bundle"
fi

cd $BUNDLE_DIR

if [ ! -z "$cflag" ]; then
  cd $BUNDLE_DIR
  if [[ $cval == git* ]] || [[ $cval == http* ]] || [[ $cval == ssh* ]]; then
    tmp=${cval##*\/}; dest=${tmp%%.git}
    git clone $cval $dest
  else
    git clone "git://github.com/${cval}.git"
  fi
fi

if [ ! -z "$Cflag" ]; then
       echo "=========================== Clone Bundles ==========================="
       # Clone bundles specified in bundles.md
       bundle_list="$HOME/vimise/bundles.md"
       # grep lines containing "**chars**", and sed plugin's name, example output: Fugitive
       pluglist="$(grep '\*\*[^\*]*\*\*' $bundle_list | sed 's/^....\([^:]*\)..:.*$/\1/')"
       cd $BUNDLE_DIR
       for f in $pluglist
       do
           # get the "git clone ..." command
           clone="$(grep $f $bundle_list | sed 's/.*`\(.*\)`.*$/\1/')"
           # get destination folder name of the "git clone" command
           fold=$(echo $clone | cut -f4 -d' ')
           if [[ ! -d "$fold" ]]; then
               echo  cloning into $fold
               # executing git clone ...
               eval $clone
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
           echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $d"
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
       echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${f%/.git}"
           (cd ${f%/.git}; git pull)
       done
       echo "=========================== Bundles Pulled Recursively ==========================="
fi

shift $(($OPTIND - 1))
