#encoding: UTF-8

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he accepts commands.
    class CommandState

      def receive_line(line)
        if line.chomp[-1] == "\\"
          @message << line.chomp[0..-2] << " "
          @keyboard_handler.reactivate(@message)
        else
          if @command_handler.command?(line)
            @command_handler.handle(line)
          else
            receive_request(line)
          end # if
        end # if
      end
      
      def receive_request(line)
        puts "Not connected. Unable to send to server."
        @keyboard_handler.reactivate
      end
      
      # Activates this state
      def activate(message="")
        @message = message
        print prompt
        @keyboard_handler.resume
      end
      
      def prompt
        "> "
      end
      
      protected
      
      # +keyboard_handler+:: An object that handles the keyboard events
      # +command_handler+:: An object that handles commands
      # +connection_handler+:: An object that handles the connections
      def initialize(keyboard_handler, command_handler, connection_manager)
        @keyboard_handler = keyboard_handler
        @command_handler = command_handler
        @connection_manager = connection_manager
      end      
    
    end
    
  end
      
end
