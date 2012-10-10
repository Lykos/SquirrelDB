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
        @signature = EM.start_server("localhost", @config[:port], ClientConnection, self, @database, @signer, @config)
      end
      
      def stop
        EventMachine.stop_server(@signature)
      end
    
    end
    
  end
  
end