#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'socket'
require 'yaml'
require 'optparse'
require 'crypto/server'
require 'fileutils'

CONFIG_DIR = '~/.config/squirreldb/server'

DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, 'config.yml')
DEFAULT_PUBLIC_KEY_FILE = File.join(CONFIG_DIR, 'public_key')
DEFAULT_PRIVATE_KEY_FILE = File.join(CONFIG_DIR, 'private_key')

DEFAULT_PORT = 52324
DEFAULT_DH_MODULUS_SIZE = 4096

DEFAULT_OPTIONS = {
  :port => DEFAULT_PORT,
  :dh_modulus_size => DEFAULT_DH_MODULUS_SIZE,
  :public_key_file => DEFAULT_PUBLIC_KEY_FILE,
  :private_key_file => DEFAULT_PRIVATE_KEY_FILE
}

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: server.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("--config FILE", "Use config file FILE") do |f|
    options[:config_file] = f
  end

  opts.on("--public FILE", "Use public key file FILE") do |f|
    options[:public_file] = f
  end

  opts.on("--private_key FILE", "Use private key file FILE") do |f|
    options[:private_key_file] = f
  end

  opts.on("--dh-modulus-size N", Integer, "Use Diffie Hellman modulus size N") do |n|
    options[:dh_modulus_size] = n
  end

  opts.on("-p", "--port N", Integer, "Use port N") do |p|
    options[:port] = p
  end

  opts.on("-f", "--[no-]force", "Overwrite existing files if necessary") do |f|
    options[:force] = f
  end

  opts.on_tail("--generate-keys N", Integer, "Generate key pair with N bits exit.") do |n|
    options[:generate_keys] = true
    options[:key_bits] = n
  end

  opts.on_tail("--generate-config", "Generate config file and exit.") do |g|
    options[:generate_config] = g
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

if options[:generate_config] && options[:generate_keys]
  puts "Only config file or key file can be generated at once."
  exit(1)
end

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
private_key_file = File.expand_path(options[:private_key_file])
if options[:generate_keys]
  if !options[:force] && File.exists?(public_key_file)
    puts "Public key file #{public_key_file} exists in file system."
    puts "Use -f to overwrite."
    exit(1)
  end
  if !options[:force] && File.exists?(private_key_file)
    puts "Private key file #{private_key_file} exists in file system."
    puts "Use -f to overwrite."
    exit(1)
  end
  public_key, private_key = Crypto::ElgamalKeyGenerator.new.generate(options[:key_bits])
  FileUtils.mkdir_p(File.dirname(public_key_file))
  File.open(public_key_file, 'w') do |f|
    f.write(public_key)
  end
  FileUtils.mkdir_p(File.dirname(private_key_file))
  File.open(private_key_file, 'w') do |f|
    f.write(private_key)
  end
  exit
end

if !File.exists?(public_key_file)
  puts "Public key file #{public_key_file} does not exist."
  puts "Specify a public key file with --public_key or generate a key pair with --generate-keys"
  exit(1)
end
if !File.exists?(private_key_file)
  puts "Private key file #{private_key_file} does not exist."
  puts "Specify a private key file with --private_key or generate a key pair with --generate-keys"
  exit(1)
end

public_key = File.binread(public_key_file)
private_key = File.binread(private_key_file)
port = options[:port]
dh_modulus_size = options[:dh_modulus_size]

puts "Starting server" if options[:verbose]
Crypto::Server.run($stdout, port, public_key, private_key, dh_modulus_size) do |client|
  ip = client.peeraddr[3]
  port = client.peeraddr[1]
  puts "Client IP:#{ip} Port:#{port} connected" if options[:verbose]
  while line = client.gets
    if line[0] == ':'
      line.slice!(0)
    else
      if line.chomp == "close"
        break
      else
        $stderr.puts "Unknown server command #{line} received from client."
      end
    end
    response = "Got message of length #{line.chomp.length} from client IP:#{ip} Port:#{port}."
    puts response if options[:verbose]
    client.puts response
  end
  puts "Client IP:#{ip} Port:#{port} disconnected." if options[:verbose]
end
