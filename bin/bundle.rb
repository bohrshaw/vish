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
        update_bundle bundle
      else
        puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Clone #{bundle_dir.capitalize}"
        puts `git clone --depth 1 #{get_url bundle}`
        update_submodules bundle_dir
      end
    end

    clean_bundles if ACTION == 'clean'
  end
end

# Pull a bundle
def update_bundle(bundle)
  author, bundle_dir = bundle.split('/')

  Dir.chdir(bundle_dir) do
    author_orig = `git config --get remote.origin.url`.split('/')[-2]

    if author != author_orig
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Update #{bundle_dir.capitalize}"
      `git remote set-url origin $bundle_url`
      `git fetch origin`
      `git reset --hard origin/HEAD`
      `git branch -u origin/HEAD`
      update_submodules '.'
    else
      if ACTION == 'pull'
        puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Update #{bundle_dir.capitalize}"
        puts `git pull`
        update_submodules '.'
      end
    end
  end
end

# Update submodules
def update_submodules(dest)
  Dir.chdir(dest) do
    `git submodule sync`
    `git submodule update --init`
  end
end

# Clean unused bundles.
def clean_bundles
  bundle_dirs = BUNDLES.map do |b|
    b.split('/')[-1]
  end

  Dir.glob('*/').each do |b|
    FileUtils.rm_rf(b) unless bundle_dirs.include? b.chomp('/')
  end
end

# Get the full URL based on partial URL like 'partial/smile.git'.
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
