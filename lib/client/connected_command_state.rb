#encoding: UTF-8

require 'client/command_state'
require 'strscan'

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he accepts commands and is connected to a server.
    class ConnectedCommandState < CommandState

      # Tells the client to add the line to the command buffer and flush it.
      def receive_request(line)
        @client.append_command_buffer(line)
        @client.flush_command_buffer
      end
      
      # Returns a prompt of the form "user@host > "
      def prompt
        @client.user + "@" + @client.host + " > " 
      end
      
    end
    
  end
      
end
