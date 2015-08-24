Param ( [Switch] $Force=$false )

# Supporting functions {{{
function New-Link {
    param([String]$target, [String]$link)

    # Generate the line path ifomitted.
    if(! $link) {
        $link = "$HOME\." + $target.split('\')[-1]
    }

    # What to do if the link is existed.
    if(Test-Path $link) {
        if($script:Force) {
            if(Test-Path -type container $link) {
                [System.IO.Directory]::Delete($link, 1)
            }
            else { remove-item $link }
        }
        else { write "$link already existed."; return }
    }

    # Create the link.
    if(Test-Path -type container $target) {
        Invoke-MKLink "/J" $link $target
    }
    else { Invoke-MKLink $link $target }
}

function Invoke-MKLink { cmd /c mklink $args }
# }}}

# Environment variables
$VISH = Split-Path $script:MyInvocation.MyCommand.Path

# Link this repository if its path isn't ~/.vim
if($VISH -ne (Convert-Path '~\.vim')) {
    New-Link $VISH $HOME\.vim
}

# Link vimrc files
New-Link "$VISH\vimrc" "$HOME\.vimrc"
New-Link "$VISH\gvimrc" "$HOME\.gvimrc"
New-Link "$VISH\vimperatorrc" "$HOME\.vimperatorrc"
New-Link "$VISH\vimperator" "$HOME\vimperator"
New-Link "$VISH\vsvimrc"

# Include spell related files(mostly static and large)
if (-not (Test-Path $VISH\spell\.git -PathType Container)) {
    if (Test-Path $VISH\spell -PathType Container) {
        mv $VISH\spell $VISH\spell.bak
    }
    git clone git@git.coding.net:bohrshaw/vish-spell.git $VISH\spell
}

# Sync bundles
if (Get-Command "go.exe" -ErrorAction SilentlyContinue) {
    Invoke-Expression "go run $VISH\bin\src\vundle\vundle.go"
} else {
    Invoke-Expression "ruby $VISH\bin\bundle.rb"
}

# vim:tw=80 ts=4 sw=4 et fdm=marker:
