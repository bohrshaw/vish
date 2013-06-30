#!/usr/bin/env ruby

require 'fileutils'

VIM_DIR = File.expand_path('..', File.dirname(__FILE__) )
BUNDLE_DIR = "#{VIM_DIR}/bundle"
BUNDLES_FILE = "#{VIM_DIR}/vimrc.bundle"

Dir.chdir BUNDLE_DIR

ACTION = ARGV.shift

# Available actions
unless [nil, 'pull', 'clean'].include? ACTION
  puts <<-'HERE'
Usage:
bundle.rb pull    -- pull all bundles when cloning
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
    dest = url.gsub(%r{^.*?://.*?/.*?/(.*?)(\.git)?$}, '\1')

    submodule_manage = proc do
      Dir.chdir(dest) { `git submodule update --init` }
    end

    unless File.exist? dest
      if File.exist? dest + '~'
        File.rename dest + '~', dest
      else
        puts "Cloning into '#{dest}'..."
        puts `git clone --depth 1 #{url}`
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
  when  %r{^(https?|git|ssh)://.*?/.*?/.*$}
    partial_url
  when %r{^[^/]+/[^/]+$}
    'git://github.com/' + partial_url + '.git'
  end
end

# Start bundle
bundle
