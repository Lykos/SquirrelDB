#encoding: UTF-8

require 'client/command_state'
require 'strscan'

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he accepts commands and is connected to a server.
    class ConnectedCommandState < CommandState

      # Splits line into SQL commands and sends them to the server.
      def receive_request(line)
        @message << " " << line
        scanner = StringScanner.new(@message)
        requests = []
        while command = scanner.scan_until(/;/)
          command.chop!
          requests << JSON::fast_generate({"request_type" => "sql", "sql" => command})
        end
        @keyboard_handler.wait_responses(requests.length, scanner.rest)
        requests.each { |request| @connection_manager.request(request) }
      end
      
      # Returns a prompt of the form "user@host > "
      def prompt
        @connection_manager.user + "@" + @connection_manager.host + " > " 
      end
      
    end
    
  end
      
end
