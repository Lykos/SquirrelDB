#encoding: UTF-8

require 'client/keyboard_handler_state'

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he accepts commands.
    class CommandState < KeyboardHandlerState

      def receive_line(line)
        if @command_handler.command?(line)
          @command_handler.handle(line)
        else
          receive_request(line)
        end # if
      end
      
      def receive_request
        puts "Not connected. Unable to send to server."
        @client.reactivate
      end
      
      # Activates this state
      def activate(message="")
        @message = message
        super()
      end
      
      def prompt
        "> "
      end
      
      protected
      
      # +keyboard_handler+:: Object which handles keyboard events.
      # +client+:: The client facade
      def initialize(keyboard_handler, client)
        super(keyboard_handler)
        @client = client
        @command_handler = client.command_handler
      end      
    
    end
    
  end
      
end
