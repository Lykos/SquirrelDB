#encoding: UTF-8

require 'client/command_state'

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he accepts commands and is connected to a server.
    class ConnectedCommandState < CommandState

      def receive_request(line)
        @message << line
        commands = @message.scan(/.*?;/)
        @message = @message.match(/(?<rest>[^;]*)$/)[:rest].to_s
          commands.each do |command|
            request = JSON::fast_generate({:request_type => :sql, :sql => command})
            begin
              JSON::load(@connection_manager.request(request))
            rescue IOError, SystemCallError => e
              puts "Error while sending to server: #{e}"
              break
            end
          end # commands.each
      end
      
      # Activates this state
      def activate(message="")
        @message = message
        print @connection_manager.user + "@" + @connection_manager.host + " > " 
        @keyboard_handler.resume
      end
      
    end
    
  end
      
end
