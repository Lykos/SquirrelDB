module RubyDB
  
  module Data

    class TupleState

      def initialize( state, tuple )
        @state = state
        @tuple = tuple
      end
      
      attr_reader :tuple

      def []( name )
        @state[name]
      end

      def []=( name, value )
        @state[name] = value
      end
      
    end

  end
  
end
