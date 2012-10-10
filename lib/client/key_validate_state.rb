require 'client/command_handler'
require 'client/response_handler'
require 'json'
require 'client/connection_manager'
require 'RubyCrypto'
gem 'eventmachine'
require 'eventmachine'

module SquirrelDB
  
  module Client
    
    class KeyValidateState
      
      def activate(host, packed_key)
      end

      def validate_key(host, packed_key)
        key = packed_key.unpack("H*")[0].encode(Encoding::UTF_8)
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
