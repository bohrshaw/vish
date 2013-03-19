#!/usr/bin/env ruby

# This tool is not a universal git repository manager. Its main usage is
# to sync vim bundles. However you may use it as a bulk repository updater.
# And you can customise this to suit your needs.
# Based on the 'thor' scripting framework.
# Documents of 'thor': https://github.com/wycats/thor/wiki

require "thor"

# A class for subcommands.
# class Subcommand < Thor
#   desc 'sync', "sync bundles"
#   option :update
#   option :delete

#   def sync(arg=nil)
#     puts "#{arg}"
#     puts options[:delete]
#   end
# end

# The main class.
class Git < Thor
  # Options for all methods inside this class.
  class_option :verbose, :type => :boolean

  # Set the working directory.
  Dir.chdir ENV['HOME'] + '/.vim/bundle'

  BUNDLES_FILE = "#{ENV['HOME']}/vimise/vimrc.bundle"

  # Conceal methods which are not tasks.
  no_tasks do
  end

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
  option :delete, :aliases => '-d', :desc => 'Delete the bundle instead of disabling it'

  def sync()
    puts 'Syncing bundles ...'

    # Get the bundle list. A bundle is like "tpope/vim-surround"
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

  # map 'u' => :update
  desc 'update [-a] [-r]', 'Update all repositories under a directory'
  option :all, :aliases => '-a', :desc => 'Update all repositories include the disabled'
  option :recursive, :aliases => '-r', :desc => 'Update all repositories recursively'

  def update(root_dir='.')
    glob_pattern = if options[:recursive] && options[:all]
                     root_dir + '/**/*/.git'
                   elsif options[:recursive]
                     # Exclude the current directory
                     root_dir + '/**/*[^~]/.git'
                   elsif options[:all]
                     root_dir + '/*/.git'
                   else
                     # Default is excluding directories ended with '~'
                     root_dir + '/*[^~]/.git'
                   end

    Dir.glob(glob_pattern) do |d|
      d.sub!(/\.git$/, '') 
      puts "Updating '#{d}'..."
      Dir.chdir(d) { puts `git pull` }
    end

    puts "Update repositories done."
  end

  # long_desc <<-LONGDESC
  #   A detail description for the subcommand.
  # LONGDESC
  # desc "subcommand command ...ARGS", "a subcommand"
  # subcommand "subcommand", Subcommand

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
        File.rename dest+'~', dest
        puts "#{dest.capitalize} enabled."
        if options[:update]
          Dir.chdir(dest) { puts `git pull` }
          puts "#{dest.capitalize} updated."
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
