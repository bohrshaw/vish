Param ( [Switch] $override=$false )

# Supporting functions#{{{
function New-Link($target, $link) {
    # What to do if the link existed.
    if (Test-Path $link) {
        if ($script:override) {
            if (Test-Path -type container $link) {
                [System.IO.Directory]::Delete($link)
            }
            else { remove-item $link }
        }
        else { write "$link already existed."; return }
    }

    # Create the link.
    if (Test-Path -type container $target) {
        Invoke-MKLink "/J" $link $target
    }
    else { Invoke-MKLink $link $target }
}

function Invoke-MKLink { cmd /c mklink $args }
#}}}

# Environment variables
$vim_dir = Split-Path $script:MyInvocation.MyCommand.Path
$sync_dir = 'D:\Sync\Skydrive'

# Link files
New-Link "$vim_dir\vim" "$HOME\.vim"
New-Link "$vim_dir\vimrc" "$HOME\.vimrc"
New-Link "$vim_dir\vimrc" "$HOME\_vimrc"
New-Link "$vim_dir\gvimrc" "$HOME\.gvimrc"

New-Link "$vim_dir\vimrc.core" "$HOME\.vimrc.core"
New-Link "$vim_dir\vimrc.light" "$HOME\.vimrc.light"
New-Link "$vim_dir\vimrc.bundle" "$HOME\.vimrc.bundle"

New-Link "$sync_dir\Documents\VimWiki" "$HOME\vimwiki"

# Sync bundles
Invoke-Expression "$vim_dir\bin\Sync-Bundle.ps1"

# vim:tw=80 ts=4 sw=4 et fdm=marker:
