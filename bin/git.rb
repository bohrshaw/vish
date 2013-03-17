#!/usr/bin/env ruby
# This is basically a git repository manager based on the 'thor' scripting framework.
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
  class_option :verbose, :type => :boolean

  # Set the working directory.
  Dir.chdir ENV['HOME'] + '/.vim/bundle'

  BUNDLES_FILE = "#{ENV['HOME']}/vimise/vimrc.bundle"

  # Conceal these methods to prevent treated like tasks.
  no_tasks do
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
            Dir.chdir(dest) { `git pull` }
            puts "#{dest.capitalize} updated."
          end
        else
          puts "Cloning into '#{dest}'..."
          `git clone #{url}`
        end
      end
    end
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

  def sync(dir='.')
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

    puts 'Syncing bundles finished.'
  end

  # map 'u' => :update
  desc 'update [-a]', 'Update all repositories under a directory'
  option :all, :aliases => '-a', :desc => 'Update all repositories include the disabled'

  def update()
    dirs = options[:all] ? Dir['*'] : (Dir['*'] - Dir['*~'])
    dirs.each do |d|
      puts "Updating '#{d}'..."
      Dir.chdir(d) { `git pull` }
    end
    puts "Updating complete."
  end

  # long_desc <<-LONGDESC
  #   A detail description for the subcommand.
  # LONGDESC
  # desc "subcommand command ...ARGS", "a subcommand"
  # subcommand "subcommand", Subcommand
end

Git.start(ARGV)
