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
OPTIONS = ARGV.join.tr('-', '')

# Prompt the usage
unless [nil, 'update', 'clean'].include? ACTION
  puts <<-'HERE'
Usage:
bundle.rb update -- update bundles
              -u -- update (the default option if omitted)
              -t -- update tracking infomation
bundle.rb clean  -- clean obsolete bundles
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
        if File.exist? bundle_dir + '~'
          File.rename bundle_dir + '~', bundle_dir
        end
        if ACTION == 'update'
          Dir.chdir(bundle_dir) { update_bundle bundle }
        end
      else
        clone_bundle bundle
      end
    end

    clean_bundles if ACTION == 'clean'
  end
end

# Update a bundle
def update_bundle(bundle)
  if OPTIONS.include?('t')
    update_tracking bundle
    update_branch
    return
  end

  if OPTIONS.include?('u') or OPTIONS == ''
    update_branch
    update_submodules
  end
end

# Update the branch tracking information
def update_tracking(bundle)
  author = bundle.split('/')[0]
  author_orig = `git ls-remote --get-url`.chomp.split(%r[/|:])[-2]

  # Update only if the current tracking remote URL contains a different author
  if author.casecmp(author_orig) != 0
    # Track an existing remote
    remote_urls = `git config --get-regex 'remote\.[^.]+\.url'`.split(/\r?\n/)
    remote_urls.each do |url|
      a_remote = url.split(/\./)[1]
      a_author = url.split(%r[/|:])[-2]

      if a_author == author
        track_remote a_remote
        return
      end
    end

    # Track a new remote if the above fails
    `git remote add #{author} #{get_url(bundle)}`
    track_remote author
  end
end

# Track the default branch of a remote from the current branch
def track_remote(remote)
  remote_branch_default = `git name-rev --name-only #{remote}`.chomp
  `git branch -u #{remote}/#{remote_branch_default}`
end

# Fetch updates and reset the current branch to the tracking remote branch
def update_branch
  # Get the name of the tracking remote of the current local branch
  branch = `git name-rev --name-only HEAD`.chomp
  remote = `git config branch.#{branch}.remote`.chomp

  puts ">>>>>>>>>>>>>>>>>>>>>>>>>>> Update #{Dir.pwd.split('/')[-1]}"
  puts `git fetch #{remote}`
  `git reset --hard #{remote}`
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
    `git submodule update --init --recursive`
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
