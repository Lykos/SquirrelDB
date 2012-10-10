#encoding: UTF-8

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he accepts commands.
    class CommandState

      def receive_line(line)
        if line.chomp[-1] == "\\"
          @message << line.chomp[0..-2] << " "
        else
          line.chomp!
          if @command_handler.command?(line)
            @command_handler.handle(line)
          else
            receive_request(line)
          end # if
        end # if
      end
      
      def receive_request(line)
        puts "Not connected. Unable to send to server."
        @keyboard_handler.activate(@keyboard_handler.command_state)
      end
      
      # Activates this state
      def activate
        @message = ""
        print "> "
        @keyboard_handler.resume
      end
      
      protected
      
      # +keyboard_handler+:: An object that handles the keyboard events
      # +command_handler+:: An object that handles commands
      def initialize(keyboard_handler, command_handler)
        @keyboard_handler = keyboard_handler
        @command_handler = command_handler
      end      
    
    end
    
  end
      
end
