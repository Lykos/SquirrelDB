require 'server/setup_state'
require 'server/connected_state'

module SquirrelDB
  
  module Server
      
    # Represents the state that the version has to be read.
    class ClientDHState < SetupState
      
      def initialize(connection, config, signer)
        super(database, connection, config)
        @protocol = ServerProtocol.new(signer, config)
      end
      
      protected
      
      # Returns the next state.
      def next_state
        ConnectedState
      end
      
      # Reads the data and returns true, if enough data is read
      def read_data(data)
        @protocol.read_client_dh_part(data)
      end
        
    end
  
  end

end
