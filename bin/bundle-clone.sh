#!/bin/bash
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
