require 'client/keyboard_handler_state'

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he has to ask for a prompt and then act accordingly.
    class PromptState < KeyboardHandlerState
      
      attr_reader :prompt
      
      # +prompt+:: The prompt to be printed.
      # +callback+:: The callback, to which the result is yielded.
      def activate(prompt, callback)
        @callback = callback
        @prompt = prompt
        super()
      end
      
      def receive_line(line)
        @callback.call(line)
      end
      
      def initialize(keyboard_handler)
        super(keyboard_handler)
      end
    
    end
    
  end
      
end
