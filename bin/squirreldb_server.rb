#!/usr/bin/ruby

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
  
require 'server/option_parser'
require 'server/database'
require 'server/option_merger'
require 'server/server_defaults'
require 'server/db_server'

DATABASE_FILE_EXTENSION = '.sqrl'

include SquirrelDB

# Parse command line options
command_options = Server::OptionParser.new.parse!(ARGV)

# Sanity checks only for the command line options
if command_options[:config_file] && !command_options[:config_file].exists?
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

# Sanity checks of whole configuration
if config[:public_key_file] == config[:private_key_file]
  puts "The public key and the private key cannot have the same file."
  exit(false)
end
if config[:database_file].extname != DATABASE_FILE_EXTENSION
  puts "The database file #{config[:database_file]}"
end

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
end

# Create keys if necessary
public_key_file = config[:public_key_file]
private_key_file = config[:private_key_file]
if config[:generate_keys]
  if !config[:key_bits]
    puts "To generate keys, the number of bits for the keys has to be specified."
  end
  both_files = [public_key_file, private_key_file]
  both_files.each do |f|
    if !config[:force] && f.exist?
      puts "Key file #{f} exists in file system."
      puts "Use -f to overwrite."
      exit(false)
    elsif !f.writable?
      puts "Key file #{f} is not writable."
      exit(false)
    elsif f.exist? && f.directory?
      puts "#{f} exists in file system and is a directory."
      exit(false)
    end
  end
  begin
    both_keys = Crypto::ElgamalKeyGenerator.new.generate(config[:key_bits])
  rescue Crypto::CryptoException => e
    puts "Error while creating keys: #{e}."
  end
  both_files.zip(both_keys).each do |f_k|
    f, k = f_k
    f.ascend do |p|
      if p.exist?
        if !p.writable?
          puts "#{p} is the first existing parent directory of the key file #{f}, but it is not writable."
          exit(false)
        else
          break
        end
      end
    end
    begin
      f.parent.mkpath
    rescue Exception => e
      puts "Error while creating the parent directories of #{f}: #{e}"
      exit(false)
    end
    begin
      f.parent.mkpath
    rescue Exception => e
      File.open(f, 'w') do |f|
        f.write(k)
      end
      puts "Error while writing key to file #{f}: #{e}"
      puts "The content of this file is now undefined."
      exit(false)
    end
  end
end

log_file = config[:log_file]
log_file.ascend do |p|
  if p.exist?
    if !p.writable?
      puts "#{p} is the first existing parent directory of the log file #{f}, but it is not writable."
      exit(false)
    else
      break
    end
  end
end
if !log_file.parent.exist?
  log_file.parent.mkpath
end

database_file = config[:database_file]
if config[:create_database]
  Server::Database.new(database_file, config.merge(:create_database => true))
end

if config[:create_config] || config[:generate_keys] || config[:create_database]
  exit
end

# Sanity checks given that the database is really started now 
if !public_key_file.exist?
  puts "Public key file #{public_key_file} does not exist."
  puts "Specify a public key file with --public_key or generate a key pair with --generate-keys"
  exit(false)
end
if !private_key_file.exist?
  puts "Private key file #{private_key_file} does not exist."
  puts "Specify a private key file with --private_key or generate a key pair with --generate-keys"
  exit(false)
end 
if !database_file.exist?
  puts "Private key file #{private_key_file} does not exist."
  puts "Specify a private key file with --private_key or generate a key pair with --generate-keys"
  exit(false)
end 
config[:public_key] = public_key_file.binread
config[:private_key] = private_key_file.binread
  
database = Server::Database.new(database_file, config)
Server::DBServer.run(database, config)
