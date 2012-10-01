require 'client/connect_id'

module SquirrelDB
  
  module Client
        
    # Handles internal commands called from the client.
    class CommandHandler
    
      def initialize(connection_manager, config)
        @connection_manager = connection_manager
        @config = config
      end
    
      def is_command?(line)
        line.start_with?(COMMAND_PREFIX)
      end
    
      def handle(line)
        command, *arguments = line[COMMAND_PREFIX.length..-1].split(/\s+/)
        puts "Got client command: #{command}"
        COMMANDS.each do |c, aliases|
          if aliases.include?(command.downcase)
            method(c).call(*arguments)
            break
          end
        end
      end
    
      private
    
      COMMAND_PREFIX = "/"
    
      COMMANDS = {
        :quit => ["q", "quit", "exit"],
        :connect => ["c", "connect"],
        :disconnect => ["d", "disconnect"]
      }
    
      def quit(*args)
        @connection_manager.disconnect if @connection_manager.connected?
        puts "Closing session."
        exit(0)
      end
    
      def disconnect(*args)
        if @connection_manager.connected?
          @connection_manager.disconnect
        else
          puts "Not connected!"
        end
      end
    
      def connect(*args)
        options = {}
        begin
          OptionParser.new do |opts|
            opts.banner = "Usage: #{$0} [options] [user@](host|alias|ipv4_address|ipv6_address)"
            opts.on("-p", "--port N", Integer, "Use port N") do |p|
              @config[:port] = p
            end
      
            opts.on("-h", "--help") do |h|
              puts opts
              return
            end
          end.parse!(args)
        rescue OptionParser::ParseError => e
          puts e
          puts connect_option_parser
        end
        connections = args.select { |arg| ConnectId::PATTERN.match(arg) }
        if connections.length == 0
          puts "No connection specified."
          return
        elsif connections.length > 1
          puts "More than one connection specified."
          return
        end
        connect_id = ConnectId.parse(connections[0])
        really_connect(connect_id.user, connect_id.host, options[:port] || @config[:port])
      end
      
      def really_connect(user, host, port)
        @connection.disconnect if @connection.connected?
        if host
          if user
            begin
              @connection_manager.connect(user, host, port)
            rescue IOError => e
              puts "Connection could not be established: #{e}"
            end
          else
            puts "Host #{host} specified, but no user and #{host} is not an alias that specifies the user."
            return
          end            
        end
      end
    
    end

  end

end