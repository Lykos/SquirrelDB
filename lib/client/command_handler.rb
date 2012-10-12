require 'client/connect_id'

module SquirrelDB
  
  module Client
        
    # Handles internal commands called from the client.
    class CommandHandler
          
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
        puts "Command not found: #{command}." unless found
      end
    
      private
    
      COMMAND_PREFIX = "/"
    
      COMMANDS = {
        :quit => ["q", "quit", "exit"],
        :connect => ["c", "connect"],
        :disconnect => ["d", "disconnect"],
        :reset => ["r", "reset"],
        :print => ["p", "print"]
      }
    
      # :doc:
      # Quits the execution.
      def quit(*args)
        @client.close_session
      end
    
      # :doc:
      # Disconnects from server.
      def disconnect(*args)
        if @client.connected?
          @client.disconnect
        else
          puts "Not connected!"
          @client.reactivate
        end
      end
    
      # :doc:
      # Connects to server. Accepts "-h" and "-p" PORT and a connection string of the form [user@](host|alias|ipv4_address|ipv6_address) as arguments.
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
              @client.reactivate
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
          @client.reactivate
          return
        elsif connections.length > 1
          puts "More than one connection specified."
          @client.reactivate
          return
        end
        connect_id = ConnectId.parse(connections[0])
        @client.connect(connect_id.user, connect_id.host, options[:port] || @config[:port])
      end
      
      # :doc:
      # Print the command buffer
      def print(*args)
        puts @client.command_buffer
        @client.reactivate
      end
      
      # :doc:
      # Resets the command buffer
      def reset(*args)
        @client.clear_command_buffer
        @client.reactivate
      end
      
      protected

      # +connection_manager+:: An object that handles the connections
      def initialize(client)
        @client = client
        @config = client.config
      end
      
    end

  end

end