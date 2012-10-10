require 'server/setup_state'
require 'server/connected_state'

module SquirrelDB
  
  module Client
      
    # Represents the state in which the client waits for the server hello.
    class ServerHelloState < Server::SetupState
      
      protected

      def initialize(connection, protocol)
        super(connection, protocol)
      end

      # Returns the class of the next state.
      def next_state_class
        ConnectedState
      end
      
      # Reads the data and returns true, if enough data is read
      def read_data(data)
        if @protocol.read_server_hello(data)
          send_data(@protocol.client_dh_part)
          true
        end
      end
        
    end
  
  end

end
