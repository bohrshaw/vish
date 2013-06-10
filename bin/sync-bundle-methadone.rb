#!/usr/bin/env ruby

require 'methadone'
require 'fileutils'

include Methadone::Main
include Methadone::CLILogging

main do |optional_arg|
  VIM_DIR = File.expand_path('..', File.dirname(__FILE__) )
  BUNDLES_FILE = "#{VIM_DIR}/vimrc.bundle"

  # Set the working directory.
  Dir.chdir "#{VIM_DIR}/bundle"

  # Get the full URL based on partial URL like 'partial/smile.git'.
  def get_url(partial_url)
    case partial_url
    when  /^(?<protocol>https?|git|ssh):\/\/(?<domain>[-A-Za-z0-9.]+)\/.*\/.*/
      partial_url
    when %r|^[^/]+/[^/]+$|
      'git://github.com/' + partial_url + '.git'
    end
  end

  # Enable the bundle if disabled(a directory name ended with ~). Otherwise clone a new one.
  def enable_or_clone_bundle(url)
    dest = url.gsub(%r|.*://.*/.*/(.*)\.git|, '\1')
    unless Dir.exists? dest
      if Dir.exists? dest + '~'
        File.rename dest+'~', dest
        puts "#{dest.capitalize} enabled."
        Dir.chdir(dest) { `git pull` } if options[:update]
      else
        puts "Cloning into '#{dest}'..."
        `git clone #{url}`
      end
    end
  end

  if options[:sync]
    puts 'Syncing bundles ...'

    # Get the bundle list. A bundle is like "tpope/vim-surround"
    # Use shell to process the bundle file
    # bundles_str = `grep '^" Bundle ' #{BUNDLES_FILE} | sed -e "s/.* '//" -e "s/'//"`
    # bundles = bundles_str.split
    # Use ruby to process the bundle file
    bundles = []
    File.open(BUNDLES_FILE, 'r') do |f|
      while line = f.gets
        bundles << line.gsub(/^" Bundle '(.*)'$/, '\1').chomp if line.match(/^" Bundle '.*/)
      end
    end

    # Enable or clone active bundles.
    bundles.each do |b|
      enable_or_clone_bundle get_url(b)
    end

    # Disable or remove unused bundles.(Old disabled bundles won't be touched.)
    (Dir['*'] - Dir['*~']).each do |d|
      match = false
      bundles.each do |b|
        b.match(/.*\/#{d}/) ? (match = true; break) : next
      end
      unless match == true
        options[:delete] ? FileUtils.rm_rf(d) : File.rename(d, d + '~')
      end
    end

    puts 'Syncing bundles done.'
  end

  if options[:clone]
    enable_or_clone_bundle get_url(options[:clone])
  end

  if options[:'update-all']
    (Dir['*'] - Dir['*~']).each do |d|
      puts "Updating '#{d}'..."
      Dir.chdir(d) { `git pull` }
    end
    puts "Updating complete."
  end

end

description "The manager for the 'vimise' vim distribution."

# Proxy to an OptionParser instance's on method
on("-s", "--sync", "Sync bundles")
on("--delete", "Delete bundles instead of renaming when syncing")
on("--update", "Update the enabled bundle when syncing")
on("-u", "--update-all", "Update all bundles")
on("-c URL", "--clone URL", "Clone a bundle")

# Command arguments.
arg :optional_arg, :optional

go!
