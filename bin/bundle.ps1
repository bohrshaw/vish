param([switch]$pull = $false, [switch]$clean = $false)

$vim_dir = ( Split-Path $script:MyInvocation.MyCommand.Path ) + '\..'
$bundle_dir = $vim_dir + '\bundle'
$bundle_file = $vim_dir + '\vimrc.bundle'

pushd $bundle_dir

# Clone or pull bundles according to bundles specification.
function Bundle-Bundle($bundles) {
    foreach ($bundle in $bundles) {
        $bundle_dir = $bundle.split('/')[-1]
        $bundle_url = 'git://github.com/' + $bundle + '.git'

        # A command to init and update git submodules
        $gsm="git submodule update --init"

        if (Test-Path $bundle_dir) {
            if ($pull) {
                cd $bundle_dir; iex "git pull;" + $gsm; cd ..
            }
        }
        else {
            iex "git clone $bundle_url"
            cd $bundle_dir; iex $gsm; cd ..
        }
    }
}

# Clean bundles according to bundles specification.
function Clean-Bundle($bundles) {
    foreach ($dir in ls) {
        foreach ($bundle in $bundles) {
            $bundle_dir = $bundle.split('/')[-1]
            if ($dir.name -eq $bundle_dir) {
                $dir_is_active = $true; break
            }
        }
        if (! $dir_is_active) {
            remove-item -recurse -force $dir
        }
    }
}

$bundles = @()
foreach ($line in [System.IO.File]::ReadLines($bundle_file)) {
    if ($line -match '^\s*Bundle ''(.*\.*)''') {
        $bundles += $line.remove(0, 10).trimend("'")
    }
}

Bundle-Bundle $bundles

if($clean) { Clean-Bundle $bundles }

popd
