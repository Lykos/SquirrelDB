module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler
    class  KeyboardHandlerState
    
      def activate
        print prompt
        @keyboard_handler.resume
      end
      
      def prompt
        "Continue? [yN] "
      end
      
      protected
      
      # +keyboard_handler+:: An object that handles keyboard input events.
      def initialize(keyboard_handler)
        @keyboard_handler = keyboard_handler
      end
        
    end
  
  end

end