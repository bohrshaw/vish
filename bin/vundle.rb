#!/usr/bin/env ruby

# Sync Vim bundles
# Author: Bohr Shaw <pubohr@gmail.com>

require 'optparse'
require 'fileutils'
require 'thwait'

# Parse command line options
OPTIONS = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: bundle.rb [options]'

  opts.separator <<-END.gsub(/^ +/, '')

    Sync bundles by default.

    Options:
  END

  opts.on('-u', '--update', 'update bundles') do
    OPTIONS[:update] = true
  end

  opts.on('-r', '--reset', 'reset the current branch') do
    OPTIONS[:reset] = true
  end

  opts.on('-c', '--clean', 'clean bundles') do
    OPTIONS[:clean] = true
  end
end.parse!

# Define constants
VIM_DIR = File.expand_path('..', File.dirname(__FILE__))
BUNDLE_DIR = "#{VIM_DIR}/bundle"
BUNDLE_FILE = "#{VIM_DIR}/vimrc.bundle"

# The bundle manager
class Bundle
  # Get the bundle list, a bundle is like "author/repo"
  # spawn 'vim -Nes --servername tmppp -S ~/.vim/vimrc.bundle'
  # sleep 0.1
  # @@bundles = `vim --servername tmppp --remote-expr bundles`.split
  # @@bundles = @@bundles.uniq # uniq! returns nil when no duplicates found
  # system('vim --servername tmppp --remote-send ":q!<CR>"')
  @@bundles = `vim -Nes "+so ~/.vim/autoload/bundle.vim |
  so ~/.vim/vimrc.bundle |put =bundles+dundles |2,p |q!"`.split

  # Get git version
  @@git_version = `git --version`

  # Sync all bundles
  def self.sync
    @@bundles.each do |bundle|
      dir = bundle.split('/')[1]
      dir_disabled = dir + '~'

      # TODO: Print necessary information during and after syncing bundles,
      # possibly using popen3. Also consider using the 'rugged' gem and the
      # 'parallel' gem.
      Thread.new do
        File.rename dir_disabled, dir if File.exist? dir_disabled
        repo = bundle.partition(%r{.+?/[^/]+})[1]
        File.exist?(dir) ? update(repo) : clone(repo)
      end

      # Limit the number of concurrent running processes.
      sleep 0.1 while Thread.list.select { |th| th.status == 'run' }.count > 20
    end

    clean if OPTIONS[:clean]
  end

  # Clone a bundle
  def self.clone(bundle)
    `git clone --depth 1 --quiet --recursive #{get_url bundle}`
  end

  # Update a bundle
  def self.update(bundle)
    author, repo = bundle.split('/')

    # Skip a non-git repository
    return unless Dir.exist? repo+'/.git'

    author_current =
      `cd #{repo} && git ls-remote --get-url`.chomp.split(/\/|:/)[-2]

    if author.casecmp(author_current) != 0
      FileUtils.rm_rf repo
      clone bundle
    elsif OPTIONS[:update]
      update_branch repo
    end
  end

  # Clean obsolete bundles.
  def self.clean
    bundle_dirs = @@bundles.map do |bdl|
      bdl.split('/')[-1]
    end

    Dir.glob('*/').each do |dir|
      FileUtils.rm_rf(dir) unless bundle_dirs.include? dir.chomp('/')
    end
  end

  private

  # Update the current branch according to its tracking remote branch
  def self.update_branch(repo)
    if OPTIONS[:reset]
      `git reset --hard origin`
    end

    `cd #{repo} && git pull`

    # Update submodules
    if File.exist? "#{repo}/.gitmodules"
      `cd #{repo} && git submodule sync \
      && git submodule update --init --recursive`
    end
  end

  # Get the full git URL based on a partial URL like 'author/repo'.
  def self.get_url(partial_url)
    case partial_url
    when  %r{^(\w+://|(.*?@)?[^.]+\.[^.]+:)}
      partial_url
    when %r{^[^/]+/[^/]+$}
      "git://github.com/#{partial_url}.git"
    else
      abort "This partial git URL '#{partial_url}' is not recognised."
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
ThreadsWait.all_waits(*(Thread.list - [Thread.main]))

# Generate Vim help tags
system('vim', '-Nesu', 'NONE', '--cmd',
       'if &rtp !~# "\v[\/]\.vim[,|$]" | set rtp^=~/.vim | endif' \
       ' | call path#inject() | Helptags | qa')

# vim:fdm=syntax: