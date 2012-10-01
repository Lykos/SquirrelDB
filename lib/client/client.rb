require 'client/command_handler'
require 'json'
require 'client/connection_manager'
require 'RubyCrypto'

module SquirrelDB
  
  module Client
    
    class Client
      
      include Crypto
      
      def prompt
        (@connection_manager.connected? ? @connection_manager.user + "@" + @connection_manager.host : "") + "> "
      end

      def validate_key(host, packed_key)
        key = packed_key.unpack("H*")[0].force_encoding(Encoding::UTF_8)
        public_key = @public_keys[host]
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
              line.chomp!
              if @command_handler.is_command?(line)
                @command_handler.handle(line)
              else
                message << line
                commands = message.scan(/.*?;/)
                message = message.match(/;(?<rest>.*?)$/)[:rest].to_s
                if @connection_manager.connected?
                  commands.each do |command|
                    request = JSON::fast_generate({:request_type => :sql, :sql => command})
                    begin
                      response = JSON::load(@connection_manager.request(request))
                    rescue IOError, SystemCallError => e
                      puts "Error while sending to server: #{e}"
                      break
                    rescue JSON::JSONError => e
                      puts "Server sent invalid JSON: #{e}."
                    end
                    case response[:response_type]
                    when :tuples
                      puts response[:tuples].map { |t| t.join "\t\t" }
                    when :command_status
                      puts response[:message] unless response[:message].empty?
                    when :error
                      puts "Error: #{response[:reason]}"
                    when :close
                      puts "#{response[:reason]}"
                      puts "connection closed."
                      @connection_manager.disconnect
                      break
                    else
                      puts "Unknown response type #{response[:response_type]}."
                    end # case
                  end # commands[0..-2].each
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
      
      protected
      
      # +config+:: A hash table that contains the configuration. If the key +:host+ is present, this is used for an initiali connection.
      def initialize(config)
        @config = config
        read_public_keys
        @connection_manager = ConnectionManager.new(config[:aliases], lambda { |host, key| validate_key(host, key) })
        @command_handler = CommandHandler.new(@connection_manager, config)
      end      
      
      private
      
      def read_public_keys
        @public_keys = @config[:public_keys_file].exist? ? YAML::load(@config[:public_keys_file].read) : {}
      end
      
      def write_public_keys
        File.open(@config[:public_keys_file], 'w') do |f|
          YAML::dump(@public_keys, f)
        end
      end
    
    end
    
  end
      
end
