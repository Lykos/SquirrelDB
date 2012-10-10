require 'eventmachine'

module SquirrelDB
  
  module Server
      
    # Represents the state that the version has to be read.
    class ReadClientHelloState
      
      VERSION_BYTES = 1 
      
      # Returns the next state.
      def next_state
        NonceReadState.new
      end
      
      # Extracts the needed information from a string that has the desired size. 
      def extract_information(data)
        data.unpack("C")[0]
      end
      
      # Returns how much data this state needs.
      def data_needed
        VERSION_BYTES
      end
        
    end
  
  end

end
