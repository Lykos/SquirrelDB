module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler.
    class KeyboardHandlerState
    
      def activate
        print prompt
        @keyboard_handler.resume
      end
      
      protected
      
      def initialize(keyboard_handler)
        @keyboard_handler = keyboard_handler
      end
    end
  
  end

end