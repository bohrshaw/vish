#!/bin/bash

# define variable
usage="Usage: $(basename $0) [-h] [-d directory] [-c repository] [-C] [-p] [-P]

Where:
    -h  show this help text
    -d  change directory, default is '$HOME/.vim/bundle'
    -c  clone a repository, either specify the full URL
        or the short form like 'tpope/vim-pathogen'
    -C  clone all repositories specified in bundles.md
        abort if the destination directory already exists
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
  echo "Cloning bundles..."
  bundle_file="$HOME/vimise/bundles.md"
  # Get the URL list of bundles and change protocol from https to git
  url_list="$(grep '^##.*http' $bundle_file | sed 's/.*(https\(.*\)).*/git\1/')"
  cd $BUNDLE_DIR
  let count=0
  for url in $url_list
  do
    tmp=${url##*\/}; dest=${tmp%%.git}
    if [ ! -d $dest ]; then
      echo "Cloning into $dest..."
      git clone $url
      let count+=1
    fi
  done
  echo "Cloning $count bundles finished."
fi

if [ ! -z "$pflag" ]; then
  echo "Pull bundles..."
  # Update all git repositories under current directory,
  # excluding directories end with '~'
  let count=0
  for d in $(ls -d *[^~])
  do
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $d"
    (cd $d; git pull)
    let count+=1
  done
  echo "Pull $count bundles finished."
fi

if [ ! -z "$Pflag" ]; then
  echo  "Pull bundles recursively..."
  # Update all git repositories under current directory recursively(maxdepth is 3),
  # excluding directories end with '~'
  let count=0
  for d in $( find . -maxdepth 3 -path '*~' -prune -o -type d -name .git -print )
  do
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${d%/.git}"
    (cd ${d%/.git}; git pull)
    let count+=1
  done
  echo  "Pull $count bundles recursively finished."
fi

shift $(($OPTIND - 1))
