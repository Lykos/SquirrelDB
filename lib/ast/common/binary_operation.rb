require 'ast/common/function_application'

module SquirrelDB

  module AST

    class BinaryOperation < FunctionApplication
    
      def initialize(operator, left, right, type=nil)
        super(type)
        @operator = operator
        @left = left
        @right = right
      end
      
      alias :operator :variable

      def left
        @arguments[0]
      end
      
      def right
        @arguments[1]
      end

      def to_s
        "(" + left.to_s + " " + operator.symbol + " " + right.to_s + ")"
      end

      def inspect
        "(" + left.inspect + " " + operator.symbol + " " + right.inspect + ")" + type_string
      end

    end

  end

end
