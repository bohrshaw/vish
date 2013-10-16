#!/usr/bin/env ruby

# Sync Vim bundles
# Author: Bohr Shaw <pubohr@gmail.com>

require 'fileutils'
require 'thwait'

# Parse the command line options
OPTIONS = ARGV.join.gsub(/\W/, '').chars

# Print usages
unless OPTIONS.sort.join =~ /^c?u?$/
  puts <<-'HERE'
Vim bundle manager, sync bundles by default.

usage: bundle.rb [options]

options: -u  update bundles
         -c  clean bundles
  HERE
  exit
end

# Define constants
VIM_DIR = File.expand_path('..', File.dirname(__FILE__) )
BUNDLE_DIR = "#{VIM_DIR}/bundle"
BUNDLE_FILE = "#{VIM_DIR}/vimrc.bundle"
GIT_THREADS = []

# The bundle manager
class Bundle
  # Get the bundle list
  BUNDLES = [] # the format of a bundle is like "author/repo"
  File.foreach(BUNDLE_FILE) do |line|
    if line =~ /^\s*Bundle '.*/
      BUNDLES << line.gsub(/^\s*Bundle ['|"](.*?)['|"].*/, '\1').chomp
    end
  end

  class << self
    # Sync all bundles
    def sync
      BUNDLES.each do |bundle|
        bundle_dir = bundle.split('/')[1]

        # todo: consider the 'rugged' gem and the 'parallel' gem.
        # todo: output the process and the result of syncing bundles (consider popen3)
        GIT_THREADS << Thread.new do
          if File.exist? bundle_dir or File.exist? bundle_dir + '~'
            File.rename bundle_dir + '~', bundle_dir if File.exist? bundle_dir + '~'
            update bundle
          else
            clone bundle
          end
        end
      end

      clean if OPTIONS.include? 'c'
    end

    # Clone a bundle
    def clone(bundle, dir = bundle.split('/')[1])
      system("git clone --depth 1 --quiet --recursive #{get_url bundle} #{dir}")
    end

    # Update a bundle
    def update(bundle)
      author, repo = bundle.split('/')
      author_current = `cd #{repo} && git ls-remote --get-url`.chomp.split(%r[/|:])[-2]

      if author.casecmp(author_current) != 0
        FileUtils.rm_rf repo
        clone bundle
      elsif OPTIONS.include? 'u'
        update_branch repo
      end
    end

    # Clean obsolete bundles.
    def clean
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

    # Get the full git URL based on a partial URL like 'author/repo'.
    def get_url(partial_url)
      case partial_url
      when  %r{^(\w+://|(.*?@)?[^.]+\.[^.]+:)}
        partial_url
      when %r{^[^/]+/[^/]+$}
        'git://github.com/' + partial_url + '.git'
      else
        abort "This partial git URL '#{partial_url}' is not recognised."
      end
    end
  end
end

# Make sure the bundle directory exists
Dir.mkdir BUNDLE_DIR unless Dir.exist? BUNDLE_DIR

# Change the current working directory
Dir.chdir BUNDLE_DIR

# Start syncing bundles
Bundle.sync

# Ensure all git operations have finished
ThreadsWait.all_waits(*GIT_THREADS)

# Generate Vim help tags
cmd = %w{vim -Nesu NONE --cmd}
cmd += ['if &rtp !~# "\v[\/]\.vim[,|$]" | set rtp^=~/.vim | endif |
        call pathway#setout() | Helptags | qa']
system(*cmd)

# vim:fdm=syntax:
