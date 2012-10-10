module SquirrelDB
  
  module Server
      
    # Represents a state of the connection during setup which reads a certain amount of data
    # and changes to the next state afterwards.
    class SetupState
      
      # Returns false, because the connection is not established yet in this state.
      def connected?
        false
      end
      
      # Reads data
      def receive_data(data)
        @data << data
        if read_data(data)
          next_state_class.new(@connection, @protocol)
        else
          self
        end
      end
      
      # Sends the given data through the connection.
      def send_data(data)
        @connection.send_data(data)
      end
      
      # Returns the class of the next state.
      def next_state_class
        raise NotImplementedError
      end
      
      # Reads the data and returns true, if enough data is read
      def read_data(data)
        raise NotImplementedError
      end
      
      protected
      
      def initialize(connection, protocol)
        @connection = connection
        @protocol = protocol
        @bytes_read = 0
        @data = ""
      end
      
    end
  
  end

end
