#!/usr/bin/env ruby

require 'fileutils'

VIM_DIR = File.expand_path('..', File.dirname(__FILE__) )
BUNDLE_DIR = "#{VIM_DIR}/bundle"
BUNDLES_FILE = "#{VIM_DIR}/vimrc.bundle"

Dir.chdir BUNDLE_DIR

ACTION = ARGV.shift

# Available actions
unless [nil, 'clone', 'pull', 'clean'].include? ACTION
  puts <<-'HERE'
Usage:
bundle.rb [clone] -- clone all bundles
bundle.rb pull    -- pull all bundles
bundle.rb clean   -- clean inactive bundles
  HERE
  exit
end

def bundle
  # Get the bundle list. A bundle is like "tpope/vim-surround"
  bundles = []
  File.foreach(BUNDLES_FILE) do |line|
    if line =~ /^\s*Bundle '.*/
      bundles << line.gsub(/^\s*Bundle '(.*)'$/, '\1').chomp
    end
  end

  # Clone or pull all bundles
  bundles.each do |b|
    url = get_url b
    dest = url.gsub(%r|.*://.*/.*/(.*)\.git|, '\1')

    submodule_manage = proc do
      Dir.chdir(dest) { `git submodule update --init` }
    end

    if ACTION == nil or ACTION == 'clone'
      unless Dir.exists? dest
        puts "Cloning into '#{dest}'..."
        puts `git clone #{url}`
        submodule_manage.call
      end
    end

    if ACTION == 'pull'
      puts "Pull #{dest.capitalize}"
      Dir.chdir(dest) { puts `git pull` }
      submodule_manage.call
    end
  end

  # Get the bundle directory list
  bundle_dirs = bundles.map do |b|
    b.split('/')[-1]
  end

  # Clean unused bundles.
  if ACTION == 'clean'
    Dir.glob('*/').each do |b|
      FileUtils.rm_rf(b) unless bundle_dirs.include? b.chomp('/')
    end
  end
end

# Get the full URL based on partial URL like 'partial/smile.git'.
def get_url(partial_url)
  case partial_url
  when  /^(?<protocol>https?|git|ssh):\/\/(?<domain>[-A-Za-z0-9.]+)\/.*\/.*/
    partial_url
  when %r|^[^/]+/[^/]+$|
    'git://github.com/' + partial_url + '.git'
  end
end

# Start bundle
bundle
