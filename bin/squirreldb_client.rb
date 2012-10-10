#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'client/client_option_parser'
require 'client/client_defaults'
require 'server/start_up_actions'
require 'client/client'

YAML_FILE_EXTENSION = '.yml'

include SquirrelDB
include Client

# Parse command line options
command_options = ClientOptionParser.new.parse!(ARGV)

# The default options
defaults = ClientDefaults.new

# Helper to perform the correct actions.
actions = Server::StartUpActions.new(command_options, defaults)

# Get config from defaults, config files and command line options
config = actions.config

# Sanity checks for the configuration
actions.check_extension(config[:config_file], YAML_FILE_EXTENSION, 'config file')
unless [:create_config, :create_database, :generate_keys].any? { |k| config[k] }
  actions.check_file_existence(command_options[:config_file], '--create-config', 'config file')
  actions.check_file_existence(command_options[:public_keys_file], '--create-config', 'config file')
end
actions.warn_main_existence

# Create config if necessary
actions.create_config

# Exit if not started in normal mode
if config[:create_config]
  exit
end

public_keys_file = config[:public_keys_file]
actions.create_parent(public_keys_file)
actions.check_writable(public_keys_file, 'public keys file', true)

# Run the client
EM.run do
  Client::Client.new(config).start
end
