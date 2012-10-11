#encoding: UTF-8

require 'client/command_state'

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he accepts commands and is connected to a server.
    class ConnectedCommandState < CommandState

      def receive_request(line)
        @message << line
        length = line.length
        commands = @message.split(";")
        @message = length == commands.map { |c| c.length + 1 }.reduce(0, :+) ? "" : commands.pop
        if commands.empty?
          @keyboard_handler.reactivate(@message)
        else
          commands.each do |command|
            request = JSON::fast_generate({"request_type" => "sql", "sql" => command})
            @connection_manager.request(request)
          end
          @keyboard_handler.wait_responses(commands.length, @message)
        end
      end
      
      def prompt
        @connection_manager.user + "@" + @connection_manager.host + " > " 
      end
      
    end
    
  end
      
end
