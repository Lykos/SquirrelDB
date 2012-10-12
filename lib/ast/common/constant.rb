require 'ast/common/expression'
require 'schema/expression_type'

module SquirrelDB

  module AST

    class Constant < Expression

      def initialize(value, type=nil)
        super(type)
        @value = value
      end
      
      include Schema
     
      TRUE = Constant.new(true, ExpressionType::BOOLEAN)
      FALSE = Constant.new(false, ExpressionType::BOOLEAN)
      NULL = Constant.new(nil, ExpressionType::NULL_TYPE)
      
      attr_reader :value
      
      def hash
        @hash ||= [super, @value].hash
      end

      def to_s
        @value.nil? ? "null" : @value.to_s
      end

      def inspect
        (@value.nil? ? "null" : @value.inspect) + type_string
      end

      def ==(other)
        super && @value == other.value
      end

    end

  end

end
