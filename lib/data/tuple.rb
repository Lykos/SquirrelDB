module SquirrelDB
  
  module Data
  
    # Represents a tuple
    class Tuple
  
      def initialize(values)
        @values = values
      end
  
      attr_reader :values
  
      def [](column)
        @values[column]
      end
  
      def []=(column, value)
        @values[column] = value
      end
      
      def to_s
        "Tuple( " + @values.collect { |v| v.to_s }.join(", ") + " )"
      end
      
      def inspect
        "Tuple( " + @values.collect { |v| v.inspect }.join(", ") + " )"
      end
  
      def +(other)
        Tuple.new(@values + other.values)
      end
      
      def dup
        Tuple.new(@values.dup)
      end
      
      def hash
        @hash ||= [super, @values].hash
      end
  
    end
  
  end

end
