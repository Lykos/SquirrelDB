require 'server/setup_state'
require 'server/client_dh_state'

module SquirrelDB
  
  module Server
      
    # Represents the state in which the server waits for the client hello.
    class ClientHelloState < SetupState
      
      protected

      # +connection+:: The object that actually communicates with the client
      # +protocol+:: The protocol which is to be executed.
      def initialize(connection, protocol)
        super(connection, protocol)
      end
      
      # Returns the class of the next state.
      def next_state_class
        ClientDHState
      end
      
      # Reads the data and returns true, if enough data is read
      def read_data(data)
        if @protocol.read_client_hello(data)
          send_data(@protocol.server_hello)
          true
        end
      end
        
    end
  
  end

end
