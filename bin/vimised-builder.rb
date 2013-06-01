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

# Refer "ftp://ftp.vim.org/pub/vim/pc/" to get the latest version number
VIM_VERSION_LATEST = '73_46'

BUNDLES_PATH = File.expand_path '~/configent/vim/vim/bundle'
VIMRC_PATH_ORIG = File.expand_path '~/configent/vim/vimrc.core'

# }}}

# BUILD_PATH = File.expand_path File.dirname(__FILE__)
BUILD_PATH = Dir.pwd

# Cd to the building directory
Dir.chdir BUILD_PATH

# Download and extract the executables and runtime files {{{
root_url = 'ftp://ftp.vim.org/pub/vim/pc/'

# GUI executable gvim##.zip
exe_file = "gvim#{VIM_VERSION_LATEST}.zip"
unless File.exist? exe_file
  `wget #{root_url}#{exe_file}`
  `unzip #{exe_file}`
end

# Runtime files vim##rt.zip
runtime_file = "vim#{VIM_VERSION_LATEST}rt.zip"
unless File.exist? runtime_file
  `wget #{root_url}#{runtime_file}`
  `unzip #{runtime_file}`
end

# You may consider manually add two alternative executables
# "gvim.exe" and "vim.exe" from "http://wyw.dcweb.cn/#download"
# }}}

VIMFILES_PATH = File.join BUILD_PATH, 'vim/vimfiles'
VIMRC_PATH = File.join BUILD_PATH, 'vim/_vimrc'
DIRS_TO_COPY = %w[ syntax spell plugin macros indent ftplugin ftdetect doc compiler colors autoload after ]

# Cd to the bundle directory
Dir.chdir BUNDLES_PATH

# Copy the files from bundles to vimfiles {{{
# Ensure destination directories exist
DIRS_TO_COPY.each do |dir|
  dir_to_create = File.join VIMFILES_PATH, dir
  mkdir_p dir_to_create unless File.directory? dir_to_create
end

# Copy standard directories recursively
Dir["**[^~]/*/"].each do |dir|
  dir_parts = dir.split('/')

  # Restrict only to valid directories
  if dir_parts.length == 2 and DIRS_TO_COPY.include? dir_parts[1]
    # todo: prompt if destination exists, compare file modification date
    cp_r( dir + '/.', VIMFILES_PATH + '/' + dir_parts[1] )
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
  # lines = File.read(path).encode!('UTF-8', 'UTF-8', :invalid => :replace).split("\n").each.reject do |line|
  lines = IO.readlines(path).reject do |line|
    line.encode!('UTF-8', 'UTF-8', :invalid => :replace)
    line =~ /^(".*|\s*)$/
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
Dir['**/*'].select do |x|
  File.file? x and File.extname(x) == '.vim'
end.each do |path|
  shrink_file path
end
# }}}

# Cd back to the building directory
Dir.chdir BUILD_PATH

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
def run_vim
  fork do
    exec("vim -u #{VIMRC_PATH} +Helptags +qall")
  end
  Process.wait
end
run_vim

# Compress the folder
`tar -cjf vimised.tar.bz2 vim`

#  vim:tw=0 ts=2 sw=2 et fdm=marker:
