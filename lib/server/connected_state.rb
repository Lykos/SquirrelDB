module SquirrelDB
  
  module Server
      
    # Represents a state of the connection after setup.
    class ConnectedState
      
      def initialize(connection, protocol)
        @connection = connection
        @protocol = protocol
        @bytes_read = 0
        @data = ""
      end
      
      # Returns true, because in this state, the connection is fully established.
      def connected?
        true
      end
      
      # Receives data and while enough data is present, a message is given to the +connection+.
      def receive_data(data)
        @data << data
        msg_data = @protocol.decrypt_verify(@data)
        while msg_data
          message, @data = msg_data
          @connection.receive_message(message)
          msg_data = @protocol.decrypt_verify(@data)
        end
        self
      end
      
      # Encrypts and signs a message and sends it.
      def send_message(data)
        @connection.send_data(@protocol.sign_encrypt(data))
      end
        
    end
  
  end

end
