#!/usr/bin/env ruby

############################################################
# This is a file to create a portable and self contained vim
# distribution officially called "vimised" for windows.
#
# However you better run this file under linux.
############################################################

require 'fileutils'
include FileUtils

# Configure before building {{{
# Latest version of vim
VIM_VERSION_LATEST = '73_46'
# Official download URL directory
URL_ROOT = 'ftp://ftp.vim.org/pub/vim/pc/'
# Non-official executables hopefully with more features
URL_ALTER = 'http://wyw.dcweb.cn/download.asp?path=vim&file=gvim73.zip'

# The path with all the third party plugins
BUNDLES_PATH = File.expand_path '~/configent/vim/vim/bundle'
# The path to your personal vimrc file
VIMRC_PATH_ORIG = File.expand_path '~/configent/vim/vimrc.core'
# }}}

# Helpers {{{
def prompt_yes_no(*args)
  loop do
    print(*args)
    result = gets.strip
    return true if result.empty? or result =~ /[y|Y]/
    return false if result =~ /[n|N]/
    next
  end
end
# }}}

# Setup the building directory and cd to it
Dir.chdir BUILD_PATH = Dir.pwd

# Pre-building checking {{{
# Clear the build directory before doing anything
if File.exist? 'vim'
  if prompt_yes_no "Warning: The 'vim' directory will be purged. Continue? (Y/n)"
    rm_r 'vim'
  else
    puts 'Sorry! You must delete the vim directory before continuing.'
    exit
  end
end
# }}}

# Download and extract the executables and runtime files {{{
def download_uncompress(url, file_name)
  unless File.exist? file_name
    `wget '#{url}' -O #{file_name}`
  end
  `unzip #{file_name}`
end

# GUI executable gvim##.zip
file_exe = "gvim#{VIM_VERSION_LATEST}.zip"
download_uncompress URL_ROOT + file_exe, file_exe

# Runtime files vim##rt.zip
file_rt = "vim#{VIM_VERSION_LATEST}rt.zip"
download_uncompress URL_ROOT + file_rt, file_rt

# Alternative executables
file_alter = 'gvim_alter.zip'
download_uncompress URL_ALTER, file_alter
`mv gvim.exe vim/vim73/gvim_alter.exe`
`mv vim.exe vim/vim73/vim.exe`
# }}}

VIMFILES_PATH = File.join BUILD_PATH, 'vim/vimfiles'
VIMRC_PATH = File.join BUILD_PATH, 'vim/_vimrc'
DIRS_TO_COPY = %w[ syntax spell plugin macros indent ftplugin ftdetect doc compiler colors autoload after ]

# Copy the files from bundles to vimfiles {{{
# Ensure destination directories exist
DIRS_TO_COPY.each do |dir|
  dir_to_create = File.join VIMFILES_PATH, dir
  mkdir_p dir_to_create unless File.directory? dir_to_create
end

# Cd to the bundle directory
Dir.chdir BUNDLES_PATH do
  # Copy standard directories recursively
  Dir["**[^~]/*/"].each do |dir|
    dir_parts = dir.split('/')

    # Restrict only to valid directories
    if dir_parts.length == 2 and DIRS_TO_COPY.include? dir_parts[1]
      # todo: prompt if destination exists, compare file modification date
      cp_r( dir + '/.', VIMFILES_PATH + '/' + dir_parts[1] )
    end
  end
end

def copy_other(bundle, *items)
  Dir.chdir(File.join(BUNDLES_PATH, bundle)) do
    cp_r items, VIMFILES_PATH
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

# Write a file to disk
def write_file(path, content)
  File.open(path, 'w') do |file|
    file.puts content
  end
end

# Shrink files
Dir["#{VIMFILES_PATH}/**/*"].select do |x|
  File.file? x and File.extname(x) == '.vim'
end.each do |path|
  shrink_file path
end
# }}}

# Generate and save a vimrc file {{{
lines_to_prepend = [ 'let g:vimfiles_path = expand("<sfile>:h") . "/vimfiles"',
  'let &rtp=g:vimfiles_path . ",$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after," . g:vimfiles_path . "/after"',
  'com Helptags silent! execute "helptags" fnameescape(g:vimfiles_path . "/doc")' ]
# 
# Todo: Change temporary files' location

vimrc_content = lines_to_prepend + IO.readlines(VIMRC_PATH_ORIG)

# Save the generated vimrc file
write_file VIMRC_PATH, vimrc_content

# Shrink vimrc
shrink_file VIMRC_PATH

# Todo: what about gvimrc
# }}}

# Generate help tags
# `vim -u #{VIMRC_PATH} +Helptags +qall`
# Fork to suppress some output warnings.
fork do
  exec("vim -u #{VIMRC_PATH} +Helptags +qall")
end
Process.wait

# Build a compressed file
`tar -cjf vimised.tar.bz2 vim`

#  vim:tw=0 ts=2 sw=2 et fdm=marker:
