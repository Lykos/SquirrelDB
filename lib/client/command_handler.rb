require 'client/connect_id'

module SquirrelDB
  
  module Client
        
    # Handles internal commands called from the client.
    class CommandHandler
      
      attr_writer :keyboard_handler
    
      # Checks if the line is a command, i.e., if it starts with the prefix "/".
      # +line+:: The potential command.  
      def command?(line)
        line.start_with?(COMMAND_PREFIX)
      end
    
      # Handles the given line as a command.
      # +line+:: The command to be handled.
      def handle(line)
        command, *arguments = line[COMMAND_PREFIX.length..-1].split(/\s+/)
        found = false
        COMMANDS.each do |c, aliases|
          if aliases.include?(command.downcase)
            method(c).call(*arguments)
            found = true
            break
          end
        end
        puts "Command not found: #{c}." unless found
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
          @keyboard_handler.reactivate
        end
      end
    
      def connect(*args)
        options = {}
        begin
          connect_option_parser = OptionParser.new do |opts|
            opts.banner = "Usage: /connect [options] [user@](host|alias|ipv4_address|ipv6_address)"
            opts.on("-p", "--port N", Integer, "Use port N") do |p|
              @config[:port] = p
            end
      
            opts.on("-h", "--help") do |h|
              puts opts
              return
            end
          end
          connect_option_parser.parse!(args)
        rescue OptionParser::ParseError => e
          puts e
          puts connect_option_parser
        end
        connections = args.select { |arg| ConnectId::PATTERN.match(arg) }
        if connections.length == 0
          puts "No connection specified."
          @keyboard_handler.reactivate
          return
        elsif connections.length > 1
          puts "More than one connection specified."
          @keyboard_handler.reactivate
          return
        end
        connect_id = ConnectId.parse(connections[0])
        @connection_manager.connect(connect_id.user, connect_id.host, options[:port] || @config[:port])
      end
      
      protected

      # +connection_manager+:: An object that handles the connections
      def initialize(connection_manager, config)
          @connection_manager = connection_manager
          @config = config
      end
      
    end

  end

end