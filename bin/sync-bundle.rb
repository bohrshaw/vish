#!/usr/bin/env ruby

# Sync vim bundles.
#
# Based on the 'thor' - 'https://github.com/wycats/thor/wiki'

require "thor"

class Bundle < Thor
  # Options for all methods inside this class.
  class_option :verbose, :type => :boolean

  THIS_FILE_DIR = File.expand_path('..', File.dirname(__FILE__) )
  VIM_DIR = THIS_FILE_DIR.gsub(/\/bin$/, '')

  BUNDLES_FILE = "#{VIM_DIR}/vimrc.bundle"

  Dir.chdir "#{VIM_DIR}/vim/bundle"

  # Make an alias to a task.
  map 's' => :sync
  long_desc <<-LONGDESC
    Enable/Clone, disable/remove bundles.
    \x5> $ git.rb sync [ --update ] [ --delete ]
  LONGDESC
  desc 'sync [-u] [-d]', "Sync bundles"
  option :update, :aliases => '-u', :desc => 'Update the just enabled bundle'
  option :clean, :aliases => '-c', :desc => 'Delete all disabled bundles'

  def sync()
    puts 'Syncing bundles ...'

    # Get the bundle list. A bundle is like "tpope/vim-surround"
    bundles = []
    File.foreach(BUNDLES_FILE) do |line|
      if line =~ /^" Bundle '.*/
        bundles << line.gsub(/^" Bundle '(.*)'$/, '\1').chomp
      end
    end

    # More readable without sacrifice performance in ruby 2.0
    # line_filter = proc { |i| i =~ /^" Bundle '.*/ }
    # bundles = File.foreach(BUNDLES_FILE).lazy.select(&line_filter).map do |l|
    #   l.gsub(/^" Bundle '(.*)'$/, '\1').chomp
    # end.to_a

    # Enable or clone active bundles.
    bundles.each do |b|
      enable_or_clone_bundle get_url(b)
    end

    # Disable unused bundles.
    (Dir['*/'] - Dir['*~/']).each do |d|
      d.chop! # remove the last '/'
      unless bundles.count { |i| i =~ /.*\/#{d}/ } >= 1
        File.rename(d, d + '~')
      end
    end

    # Delete unused bundles.
    if options[:clean]
        FileUtils.rm_rf(Dir['*~/'])
    end

    puts 'Syncing bundles done.'
  end

private
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
        puts "Enable #{dest.capitalize}"
        File.rename dest+'~', dest
      else
        puts "Cloning into '#{dest}'..."
        puts `git clone #{url}`
      end
    else
      if options[:update]
        puts "Update #{dest.capitalize}"
        Dir.chdir(dest) { puts `git pull` }
      end
    end
  end
end

# Exclude the bellow line if run 'thor install this_file'
Bundle.start
