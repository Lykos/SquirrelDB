require 'client/keyboard_handler_state'

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which an answer from the user is needed.
    class KeyValidateState < KeyboardHandlerState
    
      def activate(host, packed_key)
        key = packed_key.unpack("H*")[0].encode(Encoding::UTF_8)
        case validation_result = @key_validator.validate_key(host, key)
        when :unknown
          puts "Unknown key received from server:"
        when :invalid
          puts "Invalid key received from server:"
        when :valid
          @client.activate(:connected_command_state)
          return
        else
          raise RuntimeError, "Invalid validation result #{validation_result}."
        end
        # Only :invalid and :unknown allow that the control flow reaches this point
        puts key
        @client.activate(:prompt_state, prompt, lambda { |user_input| handle_prompt_result(host, key, user_input) } )
      end
      
      def prompt
        "Continue? [yN] "
      end
      
      protected
      
      def initialize(keyboard_handler, client)
        super(keyboard_handler)
        @client = client
        @key_validator = client.key_validator
      end
      
      private
      
      def handle_prompt_result(host, key, user_input)
        if ["y", "Y"].include?(user_input.chomp)
          @key_validator.accept(host, key)
          @client.activate(:connected_command_state)
        else
          @client.disconnect
        end
      end
        
    end
  
  end

end