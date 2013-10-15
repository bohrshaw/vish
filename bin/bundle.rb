#!/usr/bin/env ruby

# Author: Bohr Shaw <pubohr@gmail.com>
# Description: Sync Vim bundles.

require 'fileutils'
require 'thwait'

VIM_DIR = File.expand_path('..', File.dirname(__FILE__) )
BUNDLE_DIR = "#{VIM_DIR}/bundle"
BUNDLE_FILE = "#{VIM_DIR}/vimrc.bundle"

# Make sure the bundle directory exists
Dir.mkdir BUNDLE_DIR unless Dir.exist? BUNDLE_DIR

# Set the current working directory
Dir.chdir BUNDLE_DIR

# Get the bundle list
BUNDLES = [] # A bundle's format is like "user/repository"
File.foreach(BUNDLE_FILE) do |line|
  if line =~ /^\s*Bundle '.*/
    BUNDLES << line.gsub(/^\s*Bundle ['|"](.*?)['|"].*/, '\1').chomp
  end
end

# Parse the command line argument
ACTION = ARGV.shift
OPTIONS = ARGV.join.tr('-', '')

# Prompt the usage
unless [nil, 'update', 'clean'].include? ACTION
  puts <<-'HERE'
usage: bundle.rb        -- sync bundles
   or: bundle.rb update -- update bundles
   or: bundle.rb clean  -- clean bundles
  HERE
  exit
end

# Sync all bundles
def sync_bundles
  BUNDLES.each do |bundle|
    bundle_dir = bundle.split('/')[1]

    # todo: consider the 'rugged' gem the 'parallel' gem.
    # todo: output the process and the result of syncing bundles (consider popen3)
    $threads << Thread.new do
      if File.exist? bundle_dir or File.exist? bundle_dir + '~'
        File.rename bundle_dir + '~', bundle_dir if File.exist? bundle_dir + '~'
        update_bundle bundle
      else
        clone_bundle bundle
      end
    end
  end

  clean_bundles if ACTION == 'clean'
end

# Clone a bundle
def clone_bundle(bundle, dir = nil)
  dir ||= bundle.split('/')[1]
  system("git clone --depth 1 --quiet --recursive #{get_url bundle} #{dir}")
end

# Update a bundle
def update_bundle(bundle)
  author, repo = bundle.split('/')
  author_current = `cd #{repo} && git ls-remote --get-url`.chomp.split(%r[/|:])[-2]

  if author.casecmp(author_current) != 0
    FileUtils.rm_rf repo
    clone_bundle bundle
  elsif ACTION == 'update'
    update_branch repo
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

# Fetch updates and reset the current branch to the tracking remote branch
def update_branch(repo)
  # Get the tracking remote name of the current local branch
  # branch_name = `cd #{repo} && git name-rev --name-only HEAD`.chomp
  # remote_name = `cd #{repo} && git config branch.#{branch_name}.remote`.chomp
  `cd #{repo} && git fetch && git reset --hard origin`

  # Update submodules
  if File.exist? "#{repo}/.gitmodules"
    `cd #{repo} && git submodule sync && git submodule update --init --recursive`
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

# Start execution
$threads = []
sync_bundles
ThreadsWait.all_waits(*$threads)

# Generate help tags (ensure all git operations have finished)
`vim -Nesu ~/.vim/vimrc.bundle --noplugin +BundleDocs +qa`

# vim:fdm=syntax:
