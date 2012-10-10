module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which an answer from the user is needed.
    class KeyValidateState
    
      def activate(host, packed_key)
        key = packed_key.unpack("H*")[0].encode(Encoding::UTF_8)
        case validation_result = @key_validator.validate_key(host, key)
        when :unknown
          puts "Unknown key received from server: "
          puts key
          @keyboard_handler.activate(@keyboard_handler.prompt_state, "Continue? [yN] ", lambda { |l| handle_prompt_result(l) })
        when :invalid
          puts "Unknown key received from server: "
          puts key
          @keyboard_handler.activate(@keyboard_handler.prompt_state, "Continue? [yN] ", lambda { |l| handle_prompt_result(l) })

        when :valid
          @keyboard_handler.activate(@keyboard_handler.connected_command_state)
        else
          raise RuntimeError, "Invalid validation result #{validation_result}."
        end
      end
      
      protected
      
      def initialize(keyboard_handler, connection_manager, key_validator)
        @keyboard_handler = keyboard_handler
        @connection_manager = connection_manager
        @key_validator = key_validator
      end
      
      private
      
      def handle_prompt_result(line)
        if ["y", "Y"].include?(line.chomp)
          @keyboard_handler.activate(@keyboard_handler.connected_command_state)
        else
          @connection_manager.disconnect
          @keyboard_handler.activate(@keyboard_handler.command_state)
        end
      end
        
    end
  
  end

end