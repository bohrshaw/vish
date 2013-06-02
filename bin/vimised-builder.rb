#!/usr/bin/env ruby

###############################################################
# This is a file to create a portable and self contained vim
# distribution officially called "vimised" for windows(32-bit).
#
# However you should run this file under linux.
###############################################################

require 'fileutils'
include FileUtils

# Set the current working directory the building directory and cd to it
BUILD_PATH = Dir.pwd

# Configure before building {{{
# The name of this portable vim distribution
APP_NAME = 'Vimised'

# Official vim related files for windows URL
URL_ROOT = 'ftp://ftp.vim.org/pub/vim/pc/'
# Official gvim self-installing executable URL
URL_OFFICIAL = 'ftp://ftp.vim.org/pub/vim/pc/gvim73_46.exe'
# Official latest version of vim
VIM_VERSION_LATEST = '73_46'

# Cream-vim URL
URL_CREAM = 'https://downloads.sourceforge.net/project/cream/Vim/7.3.829/gvim-7-3-829.exe'
# Yongwei's executables URL
URL_YONGWEI = 'http://wyw.dcweb.cn/download.asp?path=vim&file=gvim73.zip'


# The path with all the third party plugins
BUNDLE_PATH_ORIG = File.expand_path '~/.vim/bundle'
# The plugins excluded. A plugin whose folder name ending with '~' is excluded
# by default. And It doesn't matter weather a excluded plugin exists or not.
BUNDLE_EXCLUDED = ['vim-pathogen', 'vundle', 'vim-tbone',
  'ack.vim', 'vim-ruby-debugger']

# The path to other runtime files
VIM_PATH_ORIG = File.expand_path '~/.vim'

# The path to your personal vimrc files
VIMRCS_PATH_ORIG = [ File.expand_path( '~/.vimrc.core' ),
  File.expand_path( '~/.vimrc.bundle' ) ]
# }}}

# Helpers {{{
# Ask for yes or no
def prompt_yes_no(*args)
  puts args
  print "Continue? (Y/n)"
  loop do
    result = gets.strip
    return true if result.empty? or result =~ /[y|Y]/
    return false if result =~ /[n|N]/
    print 'Answer (y/n)?'
    next
  end
end

# Write a file to disk
def write_file(path, content)
  File.open(path, 'w') do |file|
    file.puts content
  end
end
# }}}

# Pre-building checking {{{
# Notify the user what to happen before continuing
exit unless prompt_yes_no 'Start to build "Vimised" under the current direcotry.'

# Clear the build directory before doing anything
if File.exist? APP_NAME
  if prompt_yes_no "Warning: The app folder '#{APP_NAME}' will be purged."
    rm_rf APP_NAME
  else
    puts "Sorry! You must delete the #{APP_NAME} before continuing."
    exit
  end
end
# }}}

# Download and extract the executables and runtime files {{{
def download_decompress(url, file_name)
  unless File.exist? file_name
    `wget '#{url}' -O #{file_name}`
  end

  file_ext = file_name.split('.')[-1]

  if file_ext == 'zip'
    `unzip #{file_name}`
    mv 'vim', APP_NAME
  elsif file_ext == 'exe'
    `7z x -y #{file_name}`
    mkdir APP_NAME unless File.directory? APP_NAME
    mv 'vim73', APP_NAME
    cp_r '$0/.', "#{APP_NAME}/vim73"
  end
end

# Official gvim**_**.exe
# file_official = 'gvim_official.exe'
# download_decompress URL_OFFICIAL, file_official

# Cream vim
file_cream = 'gvim_cream.exe'
download_decompress URL_CREAM, file_cream

# Official archives with exe replaced {{{
# # GUI executable gvim##ole.zip
# file_exe = "gvim#{VIM_VERSION_LATEST}ole.zip"
# download_decompress URL_ROOT + file_exe, file_exe

# # Runtime files vim##rt.zip
# file_rt = "vim#{VIM_VERSION_LATEST}rt.zip"
# download_decompress URL_ROOT + file_rt, file_rt

# # Yongwei's executables
# file_yongwei = 'gvim_yongwei.zip'
# download_decompress URL_YONGWEI, file_yongwei
# `mv -f gvim.exe vim/vim73/gvim.exe`
# `mv -f vim.exe vim/vim73/vim.exe`
# }}}
# }}}

# Update runtime files {{{
# Make sure the directory for syncing runtime files with remote end exists
runtime_sync_dir = 'runtime_sync'
mkdir runtime_sync_dir unless File.directory? runtime_sync_dir

# Sync runtime files with remote end
`rsync -avzcP --delete-after ftp.nl.vim.org::Vim/runtime/dos/ #{runtime_sync_dir}`

sync_sub_dirs = ["autoload/", "colors/", "compiler/", "doc/", "ftplugin/", "indent/", "keymap/", "lang/", "macros/", "plugin/", "syntax/", "tools/", "tutor/"]

# Sync runtime files with the updated local directory.
`rsync -tvu #{runtime_sync_dir}/*.vim "#{APP_NAME}/vim73/"`
sync_sub_dirs.each do |d|
  `rsync -avu --delete #{runtime_sync_dir}/#{d} #{APP_NAME}/vim73/#{d}`
end
# }}}

# Add other runtime files(plugins) {{{
# Name the plugin folder 'bundle' other than 'vimfiles' to isolate this vim distribution.
BUNDLE_PATH = File.join BUILD_PATH, APP_NAME, 'bundle'

dirs_to_copy = %w[ syntax spell plugin macros indent ftplugin ftdetect doc compiler colors autoload after ]

# Ensure destination directories exist
dirs_to_copy.each do |dir|
  dir_to_create = File.join BUNDLE_PATH, dir
  mkdir_p dir_to_create unless File.directory? dir_to_create
end

# Get the runtime path of vim
rtp = ( Dir.glob(BUNDLE_PATH_ORIG + '/*/') + [VIM_PATH_ORIG] ).reject do |p|
  folder_name = p.split('/')[-1]
  BUNDLE_EXCLUDED.include? folder_name or folder_name =~ /~$/
end

# Copy files
rtp.each do |path|
  Dir.glob(path + '/*').each do |p|
    if File.file? p and File.extname(p) == '.vim'
      cp p, BUNDLE_PATH
    elsif File.directory? p
      folder_name = p.split('/')[-1]

      if dirs_to_copy.include? folder_name
        # todo: prompt if destination exists, compare file modification date
        cp_r p + '/.', BUNDLE_PATH + '/' + folder_name
      end
    end
  end
end

def copy_other(bundle, *items)
  plugin_path = File.join(BUNDLE_PATH_ORIG, bundle)

  return unless File.exist? plugin_path
  Dir.chdir(plugin_path) do
    cp_r items, BUNDLE_PATH
  end
end

# Copy other directories recursively
copy_other 'ultisnips', 'UltiSnips', 'utils'
copy_other 'nerdtree', 'lib', 'nerdtree_plugin'
copy_other 'syntastic', 'syntax_checkers'
# }}}

# Reduce files' size {{{
# Delete commented or empty lines and save the file
def shrink_file(path)
  # You can encode the whole file as compared to encoding per line
  # lines = File.read(path).encode!('UTF-8', 'UTF-8', :invalid => :replace).split("\n").each.reject do |line|
  lines = IO.readlines(path).reject do |line|
    # Encode to UTF-8 from UTF-8
    # line.encode!('UTF-8', 'UTF-8', :invalid => :replace)

    # If you have really troublesome input you can do a double conversion from UTF-8 to UTF-16 and back to UTF-8
    line.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    line.encode!('UTF-8', 'UTF-16')

    # Ignore a commented and empty line
    line =~ /^\s*(".*|\s*)$/
  end

  write_file path, lines
end

# Shrink rumtime and bundle files
( Dir["#{APP_NAME}/vim73/**/*"] + Dir["#{BUNDLE_PATH}/**/*"] ).select do |x|
  File.file? x and File.extname(x) == '.vim'
end.each do |file|
  shrink_file file
end
# }}}

# Generate a vimrc file {{{
VIMRC_PATH = File.join BUILD_PATH, APP_NAME, '.vimrc'

# Todo: Change temporary files' location
vimrc_content = [ 'let g:bundle_path = expand("<sfile>:h") . "/bundle"',
  'let &rtp=g:bundle_path . ",$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after," . g:bundle_path . "/after"',
  'com Helptags silent! execute "helptags" fnameescape(g:bundle_path . "/doc")' ]

VIMRCS_PATH_ORIG.each { |f| vimrc_content += IO.readlines(f) }

# Save the generated vimrc file
write_file VIMRC_PATH, vimrc_content

# Shrink vimrc
shrink_file VIMRC_PATH
# }}}

# Generate vim help tags
# `vim -u #{VIMRC_PATH} +Helptags +qall`
# Fork to suppress some output warnings.
fork { exec("vim -u #{VIMRC_PATH} +Helptags +qall") }
Process.wait

# Create batch files to launch vim with command line arguments
contents_gvim = 'start "GVim" "%~dp0vim73\gvim.exe" -u .vimrc'
contents_vim = 'start "Vim" "%~dp0vim73\vim.exe" -u .vimrc'
write_file APP_NAME + '/gvim.cmd', contents_gvim
write_file APP_NAME + '/vim.cmd', contents_vim

# Package the folder to a self executable file
`7z a -sfx Vimised.exe #{APP_NAME}`

# vim:tw=0 ts=2 sw=2 et fdm=marker:
