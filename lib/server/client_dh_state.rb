require 'server/setup_state'
require 'server/connected_state'

module SquirrelDB
  
  module Server
      
    # Represents the state that the version has to be read.
    class ClientDHState < SetupState

      # Returns the next state.
      def next_state_class
        ConnectedState
      end
      
      # Reads the data and returns true, if enough data is read
      def read_data(data)
        @protocol.read_client_dh_part(data)
      end
      
      protected

      def initialize(connection, protocol)
        super(connection, protocol)
      end
        
    end
  
  end

end
