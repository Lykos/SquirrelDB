#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'client/option_parser'
require 'client/client_defaults'
require 'server/option_merger'
require 'client/client'

include SquirrelDB

# Parse command line options
command_options = Server::OptionParser.new.parse!(ARGV)

# Sanity checks only for the command line options
if !command_options[:create_config] && command_options[:config_file] && !command_options[:config_file].exists?
  puts "Config file #{command_options[:config_file]} does not exist."
  exit(false)
end
if command_options[:public_keys_file] && !command_options[:public_keys_file].exists?
  puts "Config file #{command_options[:config_file]} does not exist."
  exit(false)
end
if !command_options[:create_config] && !defaults.user_config_file.exist?
  warn "The main configuration file #{defaults.user_config_file} is not present."
  warn "Create a default one with --create-config."
end

# merge with defaults
defaults = Server::ServerDefaults.new
config = Server::OptionMerger.new.options(defaults.default_options, defaults.config_files, command_options)

# Create config if necessary
config_file = config[:config_file]
if config[:create_config]
  if !config[:force] && config_file.exist?
    puts "Config file #{config_file} exists in file system."
    puts "Use -f to overwrite."
    exit(false)
  end
  config_file.ascend do |p|
    if p.exist?
      if !p.writable?
        puts "#{p} is the first existing parent directory of the key file #{f}, but it is not writable."
        exit(false)
      else
        break
      end
    end
  end
  config_file.mkpath
  File.open(config_file, 'w') do |f|
    YAML::dump(config.select { |k, v| k != :config_file }, f)
  end
  exit
end

public_keys_file = config[:public_keys_file]
public_keys_file.ascend do |p|
  if p.exist?
    if !p.writable?
      puts "#{p} is the first existing parent directory of the public keys file #{f}, but it is not writable."
      exit(false)
    else
      break
    end
  end
end
if !public_keys_file.parent.exist?
  public_keys_file.parent.parent.mkpath
end

# Run the client
Client.new(config).run
