#!/usr/bin/ruby

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
  
require 'server/server_option_parser'
require 'server/start_up_actions'
require 'server/database'
require 'server/server_defaults'
require 'server/db_server'
require 'server/logger_initializer'

DATABASE_FILE_EXTENSION = '.sqrl'
YAML_FILE_EXTENSION = '.yml'

include SquirrelDB
include Server

# Parse command line options
command_options = ServerOptionParser.new.parse!(ARGV)

# The default options
defaults = ServerDefaults.new

# Helper to perform the correct actions.
actions = StartUpActions.new(command_options, defaults)

# Get config from defaults, config files and command line options
config = actions.config

# Sanity checks for the configuration
actions.check_extension(config[:config_file], YAML_FILE_EXTENSION, 'config file')
actions.check_extension(config[:database_file], DATABASE_FILE_EXTENSION, 'database file')
unless [:create_config, :create_database, :generate_keys].any? { |k| config[k] }
  actions.check_file_existence(command_options[:config_file], '--create-config', 'config file')
  actions.check_file_existence(config[:database_file], '--create-database', 'database file')
  actions.check_file_existence(config[:public_key_file], '--generate-keys', 'public key file')
  actions.check_file_existence(config[:private_key_file], '--generate-keys', 'private key file')
  if config[:public_key_file] == config[:private_key_file]
    puts "Error: The public key and the private key cannot have the same file."
    exit(false)
  end
end
actions.warn_main_existence


# Create config if necessary
actions.create_config

# Create keys if necessary
public_key_file = config[:public_key_file]
private_key_file = config[:private_key_file]
if config[:generate_keys]
  actions.check_present(:key_bits, "To generate keys, the number of bits for the keys has to be specified.")
  both_files = [public_key_file, private_key_file]
  begin
    both_keys = Crypto::ElgamalKeyGenerator.new.generate(config[:key_bits])
  rescue Crypto::CryptoException => e
    puts "Error while creating keys: #{e}."
  end
  both_files.zip(both_keys).each do |f_k|
    f, k = f_k
    actions.write_file(f, k, 'key')
  end
  puts "Created new keys at #{public_key_file} and #{private_key_file}."
end

# Init logger
log_file = config[:log_file]
actions.create_parent(log_file)
actions.check_writable(log_file, 'log file', true)
LoggerInitializer.new(log_file, config).init

# Init database if necessary
database_file = config[:database_file]
if config[:create_database]
  actions.create_parent(database_file)
  actions.check_writable(database_file, 'database file')
  Database.new(database_file, config.merge(:create_database => true))
  puts "Created new database at #{database_file}."
end

# Exit if not started in normal mode
if [:create_config, :create_database, :generate_keys].any? { |k| config[k] }
  exit
end

# Read the keys
config[:public_key] = public_key_file.binread
config[:private_key] = private_key_file.binread
  
# Start the database and the server
database = Database.new(database_file, config)
DBServer.new(config).run(database)
