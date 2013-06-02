Param ( [Switch] $override=$false )

# Supporting functions#{{{
function New-Link {
    param([String]$target, [String]$link, [switch]$link_given = $false)

    # Generate the line path if omitted.
    if (! $link_given) {
        $link = "$HOME\." + $target.split('\')[-1]
    }

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
$targets = @("vim", "vimrc", "vimrc.core", "vimrc.light", "vimrc.bundle", "vsvimrc")

foreach ( $target in $targets ) { New-Link "$vim_dir\$target" }

New-Link "$sync_dir\Documents\VimWiki" "$HOME\vimwiki" -link_given

# Sync bundles
Invoke-Expression "$vim_dir\bin\Sync-Bundle.ps1"

# vim:tw=80 ts=4 sw=4 et fdm=marker:
