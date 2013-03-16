#!/usr/bin/env ruby

require 'methadone'
require 'fileutils'

include Methadone::Main
# include Methadone::CLILogging

main do |maybe|
  # Set the working directory.
  Dir.chdir ENV['HOME'] + '/.vim/bundle'

  bundles_file = "#{ENV['HOME']}/vimise/vimrc.bundle"

  # Get the bundle list in which a bundle's format is like "tpope/vim-surround"
  # Use shell to process the bundle file
  # bundles_str = `grep '^" Bundle ' #{bundles_file} | sed -e "s/.* '//" -e "s/'//"`
  # bundles = bundles_str.split
  # Use ruby to process the bundle file
  bundles = []
  File.open(bundles_file, 'r') do |f|
    while line = f.gets
      bundles << line.gsub(/^" Bundle '(.*)'$/, '\1').chomp if line.match(/^" Bundle '.*/)
    end
  end

  if options[:sync]
    puts 'Syncing bundles ...'

    # Enable or clone active bundles.
    bundles.each do |b|
      dest = b[/[^\/]*$/]
      url = 'http://github.com/' + b + '.git'

      unless Dir.exists? dest
        if Dir.exists? dest + '~'
          File.rename dest+'~', dest
        else
          `git clone #{url}`
        end
      end
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

    puts 'Syncing bundles finished.'
  end

end

description "The manager for the 'vimise' vim distribution."

# Proxy to an OptionParser instance's on method
on("-s", "--sync", "Sync bundles")
on("--delete", "Delete bundles instead of renaming")
# on("--flag VALUE")

arg :maybe, :optional

# defaults_from_env_var SOME_VAR
# defaults_from_config_file '.my_app.rc'

go!
