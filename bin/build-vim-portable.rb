#!/usr/bin/env ruby

# Deprecated!
# This script creates a portable and self contained vim distribution
# officially called "Vimind" for windows(32-bit). However you should
# run this file under linux.
#
# Author:: Bohr Shaw (mailto:pubohr@gmail.com)
# Copyright:: Copyright (c) Bohr Shaw
# License:: Distributes under the same terms as Ruby
#
# Similar works:
# https://github.com/junegunn/myvim

# Importing modules and configuration {{{1
require 'fileutils'
include FileUtils

# The name of this portable vim distribution
APP_NAME = 'Vimind'

# Official vim related files for windows URL
URL_ROOT = 'ftp://ftp.vim.org/pub/vim/pc/'
# Official gvim self-installing executable URL
URL_OFFICIAL = 'ftp://ftp.vim.org/pub/vim/pc/gvim73_46.exe'
# Official latest version of vim
VIM_VERSION_LATEST = '73_46'

# Vim latest builds
URL_LATEST = 'http://tuxproject.de/projects/vim/complete.7z'
# Cream-vim URL
URL_CREAM = 'https://downloads.sourceforge.net/project/cream/Vim/7.3.829/gvim-7-3-829.exe'
# Yongwei's executables URL
URL_YONGWEI = 'http://wyw.dcweb.cn/download.asp?path=vim&file=gvim73.zip'


# The path with all the third party plugins
BUNDLE_PATH_ORIG = File.expand_path '~/.vim/bundle'
# The plugins excluded. A plugin whose folder name ending with '~' is excluded
# by default. And It doesn't matter weather a excluded plugin exists or not.
BUNDLE_EXCLUDED = ['vim-pathogen', 'vundle', 'vim-tbone',
  'YouCompleteMe', 'ack.vim', 'vim-ruby-debugger']

# The path to other runtime files
VIM_PATH_ORIG = File.expand_path '~/.vim'

# The path to your personal vimrc files
VIMRCS_PATH_ORIG = [ File.expand_path( '~/.vimrc.core' ),
  File.expand_path( '~/.vimrc.bundle' ) ]

# Helpers {{{1
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

# Pre-building settings {{{1
# Set the current working directory the building directory
BUILD_PATH = Dir.pwd

# Notify the user what to happen before continuing
exit unless prompt_yes_no "Start to build #{APP_NAME} under the current direcotry."

# Clear the build directory before doing anything
if File.exist? APP_NAME
  if prompt_yes_no "Warning: The app folder '#{APP_NAME}' will be purged."
    rm_r APP_NAME and mkdir APP_NAME
  else
    puts "Sorry! You must delete the #{APP_NAME} before continuing."
    exit
  end
end

# Ensure the package is downloaded {{{1
def ensure_downloaded(url, file_name, override=false)
  if override or not File.exist? file_name
    `wget '#{url}' -O #{file_name}`
  end
end

# Latest gvim
pkg_name = 'vim_latest.7z'
ensure_downloaded URL_LATEST, pkg_name, true
`7z x -y -o#{APP_NAME}/vim73 #{pkg_name}`

# Official gvim
# ensure_downloaded URL_OFFICIAL, 'gvim_official.exe'

# Cream gvim
# ensure_downloaded URL_CREAM, 'gvim_cream.exe'
# `7z x -y -otmp #{file_name} `
# Dir.chdir 'tmp' do
#   cp_r '$0/.', 'vim73'
# end
# mv 'tmp/vim73', APP_NAME
# rm_r 'tmp'

# Official archives with executables replaced {{{2
# # GUI executable gvim##ole.zip
# file_exe = "gvim#{VIM_VERSION_LATEST}ole.zip"
# ensure_downloaded URL_ROOT + file_exe, file_exe

# # Runtime files vim##rt.zip
# file_rt = "vim#{VIM_VERSION_LATEST}rt.zip"
# ensure_downloaded URL_ROOT + file_rt, file_rt

# # Yongwei's executables
# ensure_downloaded URL_YONGWEI,  'gvim_yongwei.zip'
# `unzip #{file_name}`
# mv 'vim', APP_NAME
# mv 'gvim.exe', "#{APP_NAME}/vim73/gvim.exe", :force => true
# mv 'vim.exe', "#{APP_NAME}/vim73/vim.exe", :force => true

# }}}2

# Update runtime files {{{1
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

# Add other runtime files {{{1
# Name the plugin folder 'bundle' other than 'vimfiles' to isolate this vim distribution.
BUNDLE_PATH = File.join BUILD_PATH, APP_NAME, 'bundle'

# Standard folders to copy
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

# Functions for copying files safely by renaming files {{{2
# Rename a file to a non-conflicted name under its directory, so a new
# copied file will not override an existing file.
def rename_file(f)
  return unless File.file? f

  renamed_file = ''
  loop do
    renamed_file = File.basename(f) + rand(999).to_s
    break unless Dir.glob(File.dirname(f) + '/*').include? renamed_file
  end

  File.rename f, File.join(File.dirname(f), renamed_file)
  puts "#{f} renamed."
end

# Copy a file, rename a destination file if exists
def cp_custom(src, dest)
  return unless File.file? src

  dest_file = if File.directory? dest
                File.join dest, File.basename(src)
              else
                dest
              end

  rename_file dest_file if File.exist? dest_file

  cp src, dest
end

# Copy files recursively with cp_custom
def cp_r_custom(src, dest)
  return unless File.directory? dest

  if File.directory? src
    dest_dir = File.join dest, File.basename(src)

    if ! File.directory? dest_dir
      mkdir dest_dir
    elsif File.file? dest_dir
      puts "Error: Can't make #{dest_dir} as a file with the same name exists."
      exit
    end

    Dir.glob(src + '/*').each do |p|
      cp_r_custom(p, dest_dir)
    end
  elsif File.file? src
    # Ignore tags files which will be generated later
    cp_custom src, dest unless src =~ %r[doc/tags$]
  else
    puts "Error: can't find #{src}."
    exit
  end
end

# }}}2

# Copy standard directories and files
rtp.each do |path|
  Dir.glob(path + '/*').each do |p|
    if File.file? p and File.extname(p) == '.vim'
      cp_custom p, BUNDLE_PATH
    elsif File.directory? p
      folder_name = p.split('/')[-1]
      cp_r_custom p, BUNDLE_PATH if dirs_to_copy.include? folder_name
    end
  end
end

# Copy non-standard directories
def copy_other(bundle, *items)
  plugin_path = File.join(BUNDLE_PATH_ORIG, bundle)

  return unless File.exist? plugin_path
  Dir.chdir(plugin_path) do
    cp_r items, BUNDLE_PATH
  end
end
copy_other 'ultisnips', 'UltiSnips', 'utils'
copy_other 'nerdtree', 'lib', 'nerdtree_plugin'
copy_other 'syntastic', 'syntax_checkers'

# Reduce files' size {{{1
# Delete commented or empty lines and save the file
def compact(path)
  # You can encode the whole file as compared to encoding per line
  # lines = File.read(path).encode!('UTF-8', 'UTF-8', :invalid => :replace).split("\n").each.reject do |line|
  lines = IO.readlines(path).reject do |line|
    # Encode to UTF-8 from UTF-8
    # line.encode!('UTF-8', 'UTF-8', :invalid => :replace)

    # If you have really troublesome input you can do a double conversion from UTF-8 to UTF-16 and back to UTF-8
    line.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
    line.encode!('UTF-8', 'UTF-16')

    # Ignore a commented and empty line
    line =~ /^\s*(".*)?$/
  end

  write_file path, lines
end

# Shrink rumtime and bundle files
( Dir["#{APP_NAME}/vim73/**/*"] + Dir["#{BUNDLE_PATH}/**/*"] ).select do |x|
  File.file? x and File.extname(x) == '.vim'
end.each do |file|
  compact file
end

# Generate a vimrc file {{{1
vimrc_content = <<'HERE'
" Setup runtime path
let g:bundle_path = expand("<sfile>:h") . "/bundle"
let &rtp=g:bundle_path . ",$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after," . g:bundle_path . "/after"

" Define a command to generate help tags
com Helptags silent! execute "helptags" fnameescape(g:bundle_path . "/doc")

" Two commands doing nothing
command! -buffer -nargs=1 Bundle :
command! -buffer -nargs=1 Dundle :
HERE

# Concatenate vimrc contents with other vimrc files
VIMRCS_PATH_ORIG.each { |f| vimrc_content += File.read(f) }

vimrc_content += <<'HERE'
" Setup a colorscheme
if has('gui_running')
    color solarized
else
  if has('unix')
    color solarized
  else
    color vividchalk
  endif
endif
HERE

# Save the generated vimrc file
VIMRC_PATH = File.join BUILD_PATH, APP_NAME, '.vimrc'
write_file VIMRC_PATH, vimrc_content

# Shrink vimrc
compact VIMRC_PATH

# Generate vim help tags {{{1
# `vim -u #{VIMRC_PATH} +Helptags +qall`
# Fork to suppress some output warnings.
fork { exec("vim -u #{VIMRC_PATH} +Helptags +qall") }
Process.wait

# Create batch files to launch vim with command line arguments {{{1
contents_common = 'Set ws=CreateObject("WScript.Shell")' + "\r\n"
contents_gvim = 'ws.Run "vim73\gvim.exe -u .vimrc", 0, false' + "\r\n"
contents_vim = 'ws.Run "vim73\vim.exe -u .vimrc", 0, false' + "\r\n"
write_file APP_NAME + '/gvim.vbs', contents_common + contents_gvim
write_file APP_NAME + '/vim.vbs', contents_common + contents_vim

# Create a README file {{{1
contents_readme = <<'HERE'
         _           _           __
  __  __(_)___ ___  (_)___  ____/ /
 / / / / / __ `__ \/ / __ \/ __/ /
/ /_/ / / / / / / / / / / / /_/ /
\__ _/_/_/ /_/ /_/_/_/ /_/\__/_/

Enjoy the portable vim distribution!
HERE
contents_readme.gsub!(/\n/, "\r\n")

write_file APP_NAME + '/README.txt', contents_readme

# Package {{{1
`tar czf Vimind.tar.gz #{APP_NAME}`
# `7z a Vimind.7z #{APP_NAME}`

# vim:tw=0 ts=2 sw=2 et fdm=marker:
