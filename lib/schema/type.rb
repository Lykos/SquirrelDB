module SquirrelDB

  module Schema

    class Type

      def initialize( name, type_id )
        @name = name
        @type_id = type_id
      end
      
      attr_reader :name, :type_id

      INTEGER = Type.new( "Integer", 1 )
      STRING = Type.new( "String", 2 )
      BOOLEAN = Type.new( "Boolean", 3 )
      DOUBLE = Type.new( "Double", 4 )
      SHORT = Type.new( "Short", 5 )
      
      def self.by_id(id)
        case id
        when 1 then INTEGER
        when 2 then STRING
        when 3 then BOOLEAN
        when 4 then DOUBLE
        when 5 then SHORT
        end
      end

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
