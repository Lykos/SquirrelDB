require 'client/command_handler'
require 'client/connection_manager'

module SquirrelDB
  
  module Client
    
    class Client
      
      def prompt
        "#{@connection_manager.user}@#{@connection_manager.host}> " if @connection_manager.connected?
      end

      def validate_key(host, packed_key)
        key = packed_key.unpack("H*").enforce_encoding(Encoding::UTF_8)
        public_key = public_keys[host]
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
            @public_keys[host] = key
            write_public_keys
            true
          else
            false
          end
        end
      end

      # Runs the client and reads commands from stdin and handles them or sends them to the server.
      def run
        begin
          @command_handler.really_connect(@config[:user], @config[:host], @config[:port])
          message = String.new
          print prompt
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
                begin
                  response = connection.request(message)
                  puts response
                rescue
                  puts "Error while sending to server: #{response.dump}"
                end
              else
                puts "Not connected. Unable to send to server."
              end
              message.clear
            end
            print prompt
          end
          puts "Session closed"
        ensure
          @connection_manager.disconnect if @connection_manager.connected?
        end
      end
      
      protected
      
      # +config+:: A hash table that contains the configuration. If the key +:host+ is present, this is used for an initiali connection.
      def initialize(config)
        @config = config
        read_public_keys
        @connection_manager = ConnectionManager.new(config, lambda { |host, key| validate_key(host, key) })
        @command_handler = CommandHandler.new(connection, config)
      end      
      
      private
      
      def read_public_keys
        @public_keys = YAML::load(File.read(@config[:public_keys_file]))
      end
      
      def write_public_keys
        File.open(@config[:public_keys_file], 'w') do |f|
          YAML::dump(@public_keys, f)
        end
      end
    
    end
    
  end
      
end
