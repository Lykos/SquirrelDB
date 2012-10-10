module SquirrelDB
  
  module Server
      
    # Represents a state of the connection during setup which reads a certain amount of data
    # and changes to the next state afterwards.
    class SetupState
      
      def initialize(connection, protocol)
        @session = connection
        @protocol = protocol
        @bytes_read = 0
        @data = ""
      end
      
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
      
      def send_data(data)
        @session.send_data(data)
      end
      
      # Returns the class of the next state.
      def next_state_class
        raise NotImplementedError
      end
      
      # Reads the data and returns true, if enough data is read
      def read_data(data)
        raise NotImplementedError
      end
        
    end
  
  end

end
