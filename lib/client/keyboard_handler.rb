require 'client/command_handler'
require 'client/response_handler'
require 'json'
require 'client/connection_manager'
require 'RubyCrypto'
gem 'eventmachine'
require 'eventmachine'

module SquirrelDB
  
  module Client
    
    class KeyboardHandler
      
      include Crypto

      # Runs the client and reads commands from stdin and handles them or sends them to the server.
      # TODO Let EM do this as well.
      def receive_line(line)
            if line.chomp[-1] == "\\"
              message << line.chomp[0..-2] << " "
            else
              line.chomp!
              if @command_handler.is_command?(line)
                @command_handler.handle(line)
              else
                message << line
                commands = message.scan(/.*?;/)
                message = message.match(/(?<rest>[^;]*?)$/)[:rest].to_s
                if @connection_manager.connected?
                  commands.each do |command|
                    request = JSON::fast_generate({:request_type => :sql, :sql => command})
                    begin
                      JSON::load(@connection_manager.request(request))
                    rescue IOError, SystemCallError => e
                      puts "Error while sending to server: #{e}"
                      break
                    end
                  end # commands.each
                else
                  puts "Not connected. Unable to send to server."
                end #if
              end # if
            end # while
            print prompt
          end
          puts "Session closed"
        ensure
          @connection_manager.disconnect if @connection_manager.connected?
        end
      end
      
      def disconnect
        @connection_manager.disconnect
      end
      
      protected
      
      # +config+:: A hash table that contains the configuration. If the key +:host+ is present, this is used for an initial connection.
      def initialize(config)
        @config = config
        read_public_keys
        @connection_manager = ConnectionManager.new(config[:aliases], ResponseHandler.new(self), lambda { |host, key| validate_key(host, key) })
        @command_handler = CommandHandler.new(@connection_manager, config)
      end      
      
    
    end
    
  end
      
end
