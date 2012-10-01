require 'optparse'

module SquirrelDB
  
  module Client
    
    # Class responsible for parsing the command line arguments for the client
    class OptionParser
      
      # Parses the options found in argv and returns them. The options are removed from argv.
      # +argv+:: The options to be parsed, default are the command line arguments ARGV
      # *WARNING* This method uses stdout and calls exit in case of the help option or invalid options
      def parse!(argv=ARGV)
        begin
          option_parser = OptionParser.new do |opts|
            opts.accept(ConnectId, ConnectId::PATTERN) do |s|
              ConnectId.parse(s)
            end
          
            opts.banner = "Usage: #{$0} [options]"
          
            opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
              options[:verbose] = v
            end
          
            opts.on("-c", "--connect [user@](host|alias|ipv4_address|ipv6_address)", "Initially connect to given server.", ConnectId) do |c|
              options[:user] = c.user
              options[:host] = c.host
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
