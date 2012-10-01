module SquirrelDB
  
  module Data
  
    class State
  
      def initialize(values=[], base_state=nil)
        @values = values
        @base_state = base_state
      end
      
      def offset
        @offset ||= @base_state.nil? ? 0 : @base_state.offset + @base_state.length 
      end
      
      def length
        @values.length
      end
  
      def [](index)
        @values[index]
      end
      
    end

  end

end
