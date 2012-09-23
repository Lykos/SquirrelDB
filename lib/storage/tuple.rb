module SquirrelDB
  
  module Storage
  
    class Tuple
  
      def initialize( values )
        @values = values
      end
  
      attr_reader :values
  
      def []( column )
        @values[column]
      end
  
      def []=( column, value )
        @values[column] = value
      end
  
      def +(other)
        Tuple.new( @values + other.values )
      end
  
    end
  
  end

end
