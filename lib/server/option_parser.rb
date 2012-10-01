require 'optparse'
require 'pathname'

module SquirrelDB
  
  module Server
  
    # Class responsible for parsing the command line arguments for the server
    class OptionParser
            
      # Parses the options found in argv and returns them. The options are removed from argv.
      # +argv+:: The options to be parsed, default are the command line arguments ARGV
      # *WARNING* This method uses stdout and calls exit in case of the help option or invalid options
      def parse!(argv=ARGV)
        begin
          option_parser = OptionParser.new do |opts|
            opts.banner = "Usage: #{$0} [options]"
          
            opts.on("-v", "--[no-]verbose", "Run verbosely.") do |v|
              options[:verbose] = v
            end
          
            opts.on("--database FILE", "Use database file FILE.") do |f|
              options[:database_file] = Pathname.new(f)
            end
          
            opts.on("--config FILE", "Use additional config file FILE.") do |f|
              options[:config_file] = Pathname.new(f)
            end
          
            opts.on("--public_key FILE", "Use public key file FILE.") do |f|
              options[:public_key_file] = Pathname.new(f)
            end
          
            opts.on("--private_key FILE", "Use private key file FILE.") do |f|
              options[:private_key_file] = Pathname.new(f)
            end
          
            opts.on("--dh-modulus-size N", Integer, "Use Diffie Hellman modulus size N.") do |n|
              options[:dh_modulus_size] = n
            end
          
            opts.on("-p", "--port N", Integer, "Use port N.") do |p|
              options[:port] = p
            end
          
            opts.on("-f", "--[no-]force", "Overwrite existing files if necessary.") do |f|
              options[:force] = f
            end
          
            opts.on_tail("--generate-keys N", Integer, "Generate key pair with N bits exit.") do |n|
              options[:generate_keys] = true
              options[:key_bits] = n
            end
          
            opts.on_tail(
              "--create-config",
              "Create a new config file from the defaults and the specified options and exit.\n" +
              "If combined with --config, then the file specified there is used."
            ) do |g|
              options[:create_config] = g
            end
          
            opts.on_tail(
              "--create-database",
              "Create a new database file with an empty database."
            ) do |g|
              options[:create_database] = g
            end
          
            opts.on_tail("-h", "--help", "Show this message") do
              puts opts
              exit
            end
          end
          option_parser.parse!(argv)
        rescue OptionParser::ParseError => e
          puts e
          puts @option_parser
          exit(false)
        end
      end
      
    end
    
  end
  
end