#!/bin/bash
# git-clone.sh Invoke this script with zero or more arguments

pluglist=
if [[ $# == 0 ]]; then
    # grep lines containing "**chars**", and sed plugin's name, example output: Fugitive
    pluglist="$(grep '\*\*[^\*]*\*\*' bundles.md | sed 's/^....\([^:]*\)..:.*$/\1/')"
else
    # assign command line arguments
    pluglist="$@"
fi
for f in $pluglist
do
    # get the "git clone ..." command
    clone="$(grep $f bundles.md | sed 's/.*`\(.*\)`.*$/\1/')"
    # get destination folder name of the "git clone" command
    fold=$(echo $clone | cut -f4 -d' ')
    if [[ ! -d "$fold" ]]; then
        echo  cloning into $fold
        # executing git clone ...
        #eval $clone
    fi
done
