require 'ast/common/element'
require 'schema/type'

module SquirrelDB

  module AST

    class Constant < Element

      def initialize(value, type)
        @value = value
        @type = type
      end
      
      include Schema
     
      TRUE = Constant.new(true, Type::BOOLEAN)
      FALSE = Constant.new(false, Type::BOOLEAN)
      INTEGER_NULL = Constant.new(nil, Type::INTEGER)
      BOOLEAN_NULL = Constant.new(nil, Type::BOOLEAN)
      STRING_NULL = Constant.new(nil, Type::STRING)
      DOUBLE_NULL = Constant.new(nil, Type::DOUBLE)
      SHORT_NULL = Constant.new(nil, Type::SHORT)
      
      def self.null(type)
        case type
        when Type::BOOLEAN then BOOLEAN_NULL
        when Type::INTEGER then INTEGER_NULL
        when Type::SHORT then SHORT_NULL
        when Type::STRING then STRING_NULL
        when Type::DOUBLE then DOUBLE_NULL
        else
          raise "No null value known for Type #{type}."
        end
      end

      attr_reader :value, :type
      
      def hash
        @hash ||= [super, @value, @type].hash
      end

      def to_s
        @value.nil? ? "null" : @value.to_s
      end

      def inspect
        (@value.nil? ? "null" : @value.inspect) + ":" + @type.to_s
      end

      def ==(other)
        super && @type == other.type && @value == other.value
      end

      def evaluate( state )
        @value
      end

    end

  end

end
