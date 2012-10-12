require 'errors/internal_error'

module SquirrelDB

  module Schema

    # Represents one type of value which can be used for calculations.
    class ExpressionType
      
      TYPES = []

      protected
      
      def self.new(*args)
        super
      end
      
      # TODO Make the ids automatically and make it easy to iterate etc, make new private

      def initialize(name)
        @name = name
        TYPES << self
      end
      
      public
      
      attr_reader :name
    
      INTEGER = ExpressionType.new("Integer")
      STRING = ExpressionType.new("String")
      BOOLEAN = ExpressionType.new("Boolean")
      DOUBLE = ExpressionType.new("Double")
      NULL_TYPE = ExpressionType.new("NullType")
      IDENTITY = lambda { |x| x }
      

      def INTEGER.parse(string)
        string.to_i
      end
      
      def STRING.parse(string)
        string
      end
      
      def BOOLEAN.parse(string)
        case string.downcase
        when "true" then true
        when "false" then false
        else raise InternalError, "Unknown boolean #{string}."
        end
      end
      
      def DOUBLE.parse(string)
        
      end
        
      def ==(other)
        self.class == other.class &&
        @name == other.name &&
        @auto_conversions == other.auto_conversions
      end
      
      def eql?(other)
        self == other
      end
      
      def hash
        @hash ||= [self.class.hash, @name, @auto_conversions].hash
      end

      def to_s
        @name
      end

      def inspect
        "ExpressionType(#{@name})"
      end

      def auto_converts_to?(other)
        self == other || @auto_conversions.has_key?(other)
      end
      
      def auto_conversion_to(other)
        raise InternalError, "Conversion from expression type #{self} to expression type #{other} not possible." unless auto_converts_to?(other)
        if self == other then IDENTITY else @auto_conversions[other] end
      end
      
      protected
      
      attr_writer :auto_conversions
      
      INTEGER.auto_conversions = { DOUBLE => lambda { |i| i.to_f } }
      STRING.auto_conversions = {}
      BOOLEAN.auto_conversions = {}
      DOUBLE.auto_conversions = {}
      NULL_TYPE.auto_conversions = TYPES.each.with_object({}) { |t, h| h[t] = IDENTITY }
            
    end

  end
  
end
