#!/bin/bash
# Uncomment below to enable debug mode, or use 'bash -xv this_file.sh'
# Set -xv 

usage="Usage: $(basename $0) [-d directory] [-c/C repository] [-p/P] [-s/S] [-h]

Where:
    -d  change target directory, default is '$HOME/.vim/bundle'
    -c  clone a repository, either specify the full URL
        or the short form like 'tpope/vim-pathogen'
    -C  like -c, but first remove the repository if existed
    -p  pull all repositories under the 'bundle' directory
    -P  like -p, but pull recursively(max depth of directories is 3)
    -s  cloning all repositories specified in 'vimrc.bundle',
    -S  like -s, but delete unspecified repositories whose name not ended with '~'
    -h  show this help text"

hflag=; dflag=; cflag=; Cflag=; pflag=; Pflag=; sflag=; Sflag=
while getopts "hd:c:C:pPsS" name; do
    case $name in
    d)    dflag=1
          dval="$OPTARG";;
    c)    cflag=1
          cval="$OPTARG";;
    C)    Cflag=1
          Cval="$OPTARG";;
    p)    pflag=1;;
    P)    Pflag=1;;
    s)    sflag=1;;
    S)    Sflag=1;;
    h)    hflag=1;;
    ?)    printf "Usage: $(basename $0) [-h] [-d directory] [-c repository] [-C] [-p] [-P] [-s]\n" $0
          exit 2;;
    esac
done

# Get the full directory of the current script
pushd `dirname $0` > /dev/null
SCRIPT_DIR=`pwd -P`
popd > /dev/null

VIM_DIR=${SCRIPT_DIR%/*}
BUNDLE_FILE="$VIM_DIR/vimrc.bundle"

# Set up the working directory.
if [ -n "$dflag" ]; then
  BUNDLE_DIR="$dval"
else
  [ ! -d $VIM_DIR/bundle ] && mkdir "$VIM_DIR/bundle"
  BUNDLE_DIR="$VIM_DIR/bundle"
fi
cd $BUNDLE_DIR

# Clone a single repository.
if [[ -n "$cflag" ]] || [[ -n "$Cflag" ]]; then
  if [ -n "$cflag" ]; then
    src=$cval
  else
    src=$Cval
  fi
  # Truncate the repository URL to e.g. bohrshaw/vimise
  if [[ $src == git:\/\/* ]] || [[ $src == http:\/\/* ]] || [[ $src == https:\/\/* ]] || [[ $src == ssh:\/\/* ]]; then
    src=${src##*github.com\/}
    src=${src%%.git}
  fi

  # Delete the directory if exsited.
  if [ -n "$Cflag" ]; then
    dest=${src##*\/}
    if [ -d $dest ]; then
      rm -rf $dest
    fi
  fi

  git clone "git://github.com/${src}.git"
fi

# Update all git repositories.
if [[ -n "$pflag" ]] || [[ -n "$Pflag" ]]; then
  # Update all the repositories under the current working path.
  if [ -n "$pflag" ]; then
    echo "Pull bundles ..."
    let count=0
    # Excluding directories end with '~'
    for d in $(ls -d *[^~]); do
      echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $d"
      (cd $d; git pull)
      let count+=1
    done
    echo "Pull $count bundles done"
  fi

  # Update all the repositories RECURSIVELY under the current working path.
  if [ -n "$Pflag" ]; then
    echo  "Pull bundles recursively ..."
    let count=0
    # Don't descent into a directory which is a git repository
    # and exclude directories end with '~'
    #for d in $( find . -exec test -d '{}'/.git \; ! -path '*~' -print -prune ); do
    # As the above don't work in msysgit bash, here comes a solution of compromise.
    for d in $( find . -maxdepth 3 -path "*~" -prune -o \
                      -type d -name ".git" -print -prune ); do
      echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${d%/.git}"
      (cd ${d%/.git}; git pull)
      let count+=1
    done
    echo  "Pull $count bundles recursively done"
  fi
fi

# Sync repositories according bundles specified in the BUNDLE_FILE.
if [[ -n "$sflag" ]] || [[ -n "$Sflag" ]]; then
  echo "Syncing bundles(directories) ..."
  bundle_list="$(grep '^" Bundle ' $BUNDLE_FILE | sed "s/.*\/\(.*\)'/\1/")"
  # Get the URL list of bundles, the format '\'' match a '
  url_list="$(grep '^" Bundle ' $BUNDLE_FILE \
    | sed 's_" Bundle '\''\(.*\)'\''_http://github.com/\1.git_')"

  let count=0
  for url in $url_list; do
    tmp=${url##*\/}; dest=${tmp%%.git}
    if [ ! -d $dest ]; then
      echo "Cloning into $dest ..."
      # Reuse the disabled repository instead of cloning a new one.
      if [ -d $dest~ ]; then
        mv $dest~ $dest
      else
        git clone $url
        let count+=1
      fi
    fi
  done

  echo "Cloning $count bundles done"

  # Disable or delete(Sflag) repositories not specified in the BUNDLE_FILE.
  dir_list="$(ls -d *[^~])" # Exclude directories already ended with "~".
  for i in $dir_list; do
    match=false
    for j in $bundle_list; do
      [[ "$i" == "$j" ]] && match=true && break
    done
    if ! $match; then
      # Ternary operator "...?...:..." in shell's form. But the 3rd part is also executed when the 2nd part failed.
      [[ -n $Sflag ]] &&  rm -rf $i || mv $i $i~
    fi
  done

  echo "Syncing bundles(directories) done"
fi

# Display help.
if [ -n "$hflag" ] || [ $# -eq 0 ]; then
  echo "$usage" >&2
fi

shift $(($OPTIND - 1))
