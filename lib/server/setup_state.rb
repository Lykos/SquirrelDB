require 'eventmachine'

module SquirrelDB
  
  module Server
      
    # Represents a state of the connection during setup which reads a certain amount of data
    # and changes to the next state afterwards.
    class SetupState
      
      def initialize(session)
        @session = session
        @bytes_read = 0
        @data = ""
      end
      
      # Reads data
      def receive_data(data)
        @data << data
        if @data >= data_needed
          extract_information(@data.slice!(0, data_needed))
          new_state = next_state
          new_state.receive_data(@data)
        else
          self
        end
      end
      
      def send_data(data)
        @session.send_data(data)
      end
      
      # Returns the next state.
      def next_state
        raise NotImplementedError
      end
      
      # Extracts the needed information from a string that has the desired size. 
      def extract_information(data)
        raise NotImplementedError
      end
      
      # Returns how much data this state needs.
      def data_needed
        raise NotImplementedError
      end
        
    end
  
  end

end
