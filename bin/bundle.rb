#!/usr/bin/env ruby

# Author: Bohr Shaw <pubohr@gmail.com>
# Description: Sync Vim bundles.

require 'fileutils'

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
    Thread.new do
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

  # Update the branch if the repository author not matching the bundle author
  if author.casecmp(author_current) != 0
    remote_urls = %x(cd #{repo} && git config --get-regex remote\.\\S+\.url).split(/\r?\n/)

    # Check if the remote URL are already existed
    is_remote_existed, remote_name = nil
    remote_urls.each do |url|
      if author == url.split(%r[/|:])[-2]
        is_remote_existed = true
        remote_name = url.split(/\./)[1]
        break
      end
    end

    # Add the bundle remote if not existing
    unless is_remote_existed
      # todo: track the default remote branch instead of 'master'
      `cd #{repo} && git remote add -t master #{author} #{get_url(bundle)}`
      remote_name = author
    end

    # Track the default remote branch from the current branch
    `cd #{repo} && git branch -u #{remote_name}/master`

    update_branch repo, remote_name
    return
  end

  if ACTION == 'update'
    # Get the name of the tracking remote of the current local branch
    branch_name = `cd #{repo} && git name-rev --name-only HEAD`.chomp
    remote_name = `cd #{repo} && git config branch.#{branch_name}.remote`.chomp

    update_branch repo, remote_name
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
def update_branch(repo, remote_name)
  # todo: shallow fetch a new remote
  `cd #{repo} && git fetch #{remote_name} && git reset --hard #{remote_name}/master`

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

# Execute
sync_bundles

# Generate help tags
`vim -Nesu ~/.vim/vimrc.bundle --noplugin +BundleDocs +qa`

# vim:fdm=syntax:
