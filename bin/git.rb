#!/usr/bin/env ruby

# This tool is not a universal git repository manager. Its main usage is
# to sync vim bundles. However you may use it as a bulk repository updater.
# And you can customise this to suit your needs.
# Based on the 'thor' scripting framework.
# Documents of 'thor': https://github.com/wycats/thor/wiki

require "thor"

# A class for a subcommand.(demo)
class Subcommand < Thor
  desc 'sync', "sync bundles"
  option :update
  option :delete

  def sync(arg=nil)
    puts "#{arg}"
    puts options[:delete]
  end
end

# The main class.
class Git < Thor
  # Options for all methods inside this class.
  class_option :verbose, :type => :boolean

  # Set the working directory.
  Dir.chdir ENV['HOME'] + '/.vim/bundle'

  BUNDLES_FILE = "#{ENV['HOME']}/vimise/vimrc.bundle"

  # Make an alias to a task.
  # map 's' => :sync
  long_desc <<-LONGDESC
    Enable/Clone, disable/remove bundles.
    \x5> $ git.rb sync [ --update ] [ --delete ]
  LONGDESC
  # Usage and short description.
  desc 'sync [-u] [-d]', "Sync bundles"
  # option is an alias for method_option
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

    # Disable or clean unused bundles.
    (Dir['*/'] - Dir['*~/']).each do |d|
      d.chop! # remove the last '/'
      unless bundles.count { |i| i =~ /.*\/#{d}/ } >= 1
        options[:clean] ? FileUtils.rm_rf(d) : File.rename(d, d + '~')
      end
    end
    if options[:clean]
        FileUtils.rm_rf(Dir['*~/'])
    end

    puts 'Syncing bundles done.'
  end

  # map 'u' => :update
  desc 'update [-a] [-r]', 'Update all repositories under a directory'
  option :all, :aliases => '-a', :desc => 'Update all repositories include the disabled'
  option :recursive, :aliases => '-r', :desc => 'Update all repositories recursively'

  def update(root_dir='.')
    pattern_prepend = root_dir[-1] == '/' ? root_dir.chop : root_dir

    Dir.glob(pattern_prepend + glob_pattern) do |d|
      d.sub!(/\.git$/, '') 
      puts "Updating '#{d}'..."
      Dir.chdir(d) { puts `git pull` }
    end
    puts "Update repositories done."
  end

  # Conceal methods that are not tasks.
  no_tasks do
    def glob_pattern
      if options[:recursive] && options[:all]
        '/**/*/.git'
      elsif options[:recursive]
        '/**/*[^~]/.git' # Exclude the current directory
      elsif options[:all]
        '/*/.git'
      else
        '/*[^~]/.git'
      end
    end
  end

  desc "subcommand command ...ARGS", "a subcommand"
  subcommand "subcommand", Subcommand

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

        if options[:update]
          puts "Update #{dest.capitalize}"
          Dir.chdir(dest) { puts `git pull` }
        end
      else
        puts "Cloning into '#{dest}'..."
        puts `git clone #{url}`
      end
    end
  end
end

# Exclude the bellow line if run 'thor install this_file'
Git.start
