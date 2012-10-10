require 'eventmachine'

module SquirrelDB
  
  module Server
    
    class ClientSession < EventMachine::Connection
      
      # +database+:: The database
      # +config+:: A hash table containing at least the keys +:port+, +:public_key+, +:private_key+
      #            and +:dh_modulus_size+
      def initialize(database, config)
        @database = database
        @config = config
        @log = Logging.logger[self]
        @stop_mutex = Mutex.new
        @state = UnconnectedState.new(self)
      end
      
      attr_reader :log
      
      def receive_data(data)
        @state = @state.receive_data(data)
      end
        
    end
    
  end

end
