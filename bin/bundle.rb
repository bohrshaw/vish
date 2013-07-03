#!/usr/bin/env ruby

# Author: Bohr Shaw(pubohr@gmail.com)
# Description: Sync vim bundles.

# Settings {{{
require 'fileutils'

VIM_DIR = File.expand_path('..', File.dirname(__FILE__) )
BUNDLE_DIR = "#{VIM_DIR}/bundle"
BUNDLE_FILE = "#{VIM_DIR}/vimrc.bundle"

# Get the bundle list
BUNDLES = [] # A bundle's format is like "user/repository"
File.foreach(BUNDLE_FILE) do |line|
  if line =~ /^\s*Bundle '.*/
    BUNDLES << line.gsub(/^\s*Bundle '(.*)'$/, '\1').chomp
  end
end

# Parse the command line argument
ACTION = ARGV.shift

# Prompt the usage
unless [nil, 'pull', 'clean'].include? ACTION
  puts <<-'HERE'
Usage:
bundle.rb pull    -- pull all bundles when cloning
bundle.rb clean   -- clean inactive bundles
  HERE
  exit
end

# }}}

# Sync all bundles
def sync_bundles
  Dir.chdir(BUNDLE_DIR) do
    BUNDLES.each do |bundle|
      bundle_dir = bundle.split('/')[1]

      if File.exist? bundle_dir or File.exist? bundle_dir + '~'
        File.rename bundle_dir + '~', bundle_dir if File.exist? bundle_dir + '~'
        Dir.chdir(bundle_dir) { update_bundle bundle }
      else
        clone_bundle bundle
      end
    end

    clean_bundles if ACTION == 'clean'
  end
end

# Pull a bundle
def update_bundle(bundle)
  author, bundle_dir = bundle.split('/')
  author_orig = `git config --get remote.origin.url`.split('/')[-2]

  if author != author_orig
    FileUtils.rm_rf '.'
    clone_bundle bundle, '.'
  elsif ACTION == 'pull'
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Update #{bundle_dir.capitalize}"
    puts `git pull`
    update_submodules
  end
end

# Clone a bundle
def clone_bundle(bundle, dest_dir = nil)
  bundle_dir = bundle.split('/')[1]
  dest_dir ||= bundle_dir
  puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Clone #{bundle_dir.capitalize}"
  puts `git clone --depth 1 #{get_url bundle} #{dest_dir}`
  Dir.chdir(dest_dir) { update_submodules }
end

# Update submodules
def update_submodules
  if File.exist? '.gitmodules'
    `git submodule sync`
    `git submodule update --init`
  end
end

# Clean obsolete bundles.
def clean_bundles
  bundle_dirs = BUNDLES.map do |b|
    b.split('/')[-1]
  end

  Dir.glob('*/').each do |b|
    FileUtils.rm_rf(b) unless bundle_dirs.include? b.chomp('/')
  end
end

# Get the full URL based on a partial URL like 'partial/smile.git'.
def get_url(partial_url)
  case partial_url
  when  %r{^(https?|git|ssh)://.*?/.*?/.*$}
    partial_url
  when %r{^[^/]+/[^/]+$}
    'git://github.com/' + partial_url + '.git'
  end
end

# Execute
sync_bundles

# vim:fdm=marker:
