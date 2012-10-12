require 'ast/common/function_application'

module SquirrelDB

  module AST

    class UnaryOperation < FunctionApplication

      def initialize(operator, inner, type=nil)
        super(operator, [inner], type)
      end

      alias :operator :variable
      
      def inner
        @arguments[0]
      end
            
      def to_s
        "(" + operator.symbol + inner.to_s + ")"
      end

      def inspect
        "(" + operator.symbol + inner.inspect + ")" + type_string
      end
      
    end

  end

end
