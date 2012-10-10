require 'server/client_connection'
require 'RubyCrypto'

module SquirrelDB
  
  module Server
    
    class DBServer
      
      def initialize(database, config)
        @database = database
        @config = config
        @signer = Crypto::ElgamalSigner.new(config[:private_key])
      end
      
      def start
        @signature = EM.start_server("127.0.0.1", 6667, ClientConnection, self, @database, @signer, @config)
      end
      
      def stop
        EventMachine.stop_server(@signature)
    
        unless wait_for_connections_and_stop
          EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
        end
      end
    
    end
    
  end
  
end