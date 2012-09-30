#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'command_handler'
require 'yaml'
require 'optparse'
require 'fileutils'
require 'client_connection'
require 'connect_id'

CONFIG_DIR = '~/.config/squirreldb/client'

LINE_START = '> '

DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, 'config.yml')
DEFAULT_PUBLIC_KEY_FILE = File.join(CONFIG_DIR, 'public_keys.yml')
DEFAULT_PORT = 52324
DEFAULT_USER = ENV["LOGNAME"]

DEFAULT_OPTIONS = {
  :port => DEFAULT_PORT,
  :public_key_file => DEFAULT_PUBLIC_KEY_FILE,
  :default_user => DEFAULT_USER,
  :aliases => {}
}

options = {}
OptionParser.new do |opts|
  opts.accept(ConnectId, ConnectId::PATTERN) do |s|
    ConnectId.parse(s)
  end

  opts.banner = "Usage: server.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-c", "--connect [user@](hostname|alias|ipv4_address|ipv6_address)", "Initially connect to given server.", ConnectId) do |c|
    options[:user] = c.user
    options[:hostname] = c.hostname
  end

  opts.on("--config FILE", "Use config file FILE") do |f|
    options[:config_file] = f
  end

  opts.on("-p", "--port N", Integer, "Use port N") do |p|
    options[:port] = p
  end

  opts.on("-f", "--[no-]force", "Overwrite existing files if necessary") do |f|
    options[:force] = f
  end

  opts.on("--public-keys FILE", "Use FILE to look up/store public keys of servers") do |f|
    options[:public_key_file] = f
  end

  opts.on_tail("--generate-config", "Generate config file and exit.") do |g|
    options[:generate_config] = g
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

config_file = File.expand_path(options[:config_file] || DEFAULT_CONFIG_FILE)
if options[:generate_config]
  if !options[:force] && File.exists?(config_file)
    puts "Config file #{config_file} exists in file system."
    puts "Use -f to overwrite."
    exit(1)
  end
  config = {}
  DEFAULT_OPTIONS.each do |k, v|
    config[k] = options[k] || v
  end
  FileUtils.mkdir_p(File.dirname(config_file))
  File.open(config_file, 'w') do |f|
    YAML::dump(config, f)
  end
  exit
end

config = if File.exists?(config_file)
           YAML::load(File.read(config_file))
         else
           {}
         end
options = DEFAULT_OPTIONS.merge(config).merge(options)

public_key_file = File.expand_path(options[:public_key_file])
public_keys = if File.exists?(public_key_file)
                YAML::load(File.read(public_key_file))
              else
                {}
              end

validate_key = lambda do |hostname, packed_key|
  key = packed_key.unpack("H*")
  public_key = public_keys[hostname]
  if public_key == key
    true
  else
    if public_key
      puts "Invalid public key sent by server."
      puts key
    else
      puts "Unknown public key sent by server."
      puts key
    end
    puts "Continue? [yN]"
    if ['y', 'Y'].include?(gets.chomp)
      public_keys[hostname] = key
      FileUtils.mkdir_p(File.dirname(public_key_file)) unless File.exists?(public_key_file)
      File.open(public_key_file, 'w') do |f|
        YAML::dump(public_keys, f)
      end
      true
    else
      false
    end
  end
end
options[:user] ||= options[:default_user]

ClientConnection.open($stdout, options[:aliases], validate_key) do |connection|
  command_handler = CommandHandler.new($stdin, $stdout, $stderr, connection, options)
  connection.connect(options[:user], options[:hostname], options[:port]) if options[:hostname]
  message = String.new
  print LINE_START
  while line = gets
    if line.chomp[-1] == "\\"
      message << line.chomp[0..-2] << " "
    else
      message << line.chomp
      if command_handler.is_command?(message)
        command_handler.handle(message)
      elsif message.empty?
        # ignore message
      elsif connection.connected?
        response = connection.request(message)
        puts "Server: " + response
      else
        puts "Not connected. Unable to send to server."
      end
      message.clear
    end
    print LINE_START
  end
end
puts "Session closed"
