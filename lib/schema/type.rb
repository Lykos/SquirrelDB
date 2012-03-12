module RubyDB

  module Schema

    class Type

      def initialize( name )
        @name = name
      end
      
      attr_reader :name

      INTEGER = Type.new( "Integer" )
      STRING = Type.new( "String" )
      BOOLEAN = Type.new( "Boolean" )
      DOUBLE = Type.new( "Double" )
      SHORT = Type.new( "Short" )

      def ==(other)
        @name == other.name
      end

      def to_s
        @name
      end

      def inspect
        @name
      end

      def converts_to?( other_type )
        self == other_type || conversions.any? { |c| c.to_type == other_type }
      end

      def convert_to( other_type, value )
        return value if self == other_type
        conversion = conversions.find { |c| c.tol_type == other_type }
        raise unless conversion
        conversion.convert( value )
      end

      def conversions
        @conversions ||= Conversions.from( self )
      end

    end

  end
  
end
