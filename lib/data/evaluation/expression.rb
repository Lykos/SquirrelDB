require 'sql/elements/operator'

module RubyDB

  module Data
  
    class Expression

      def initialize( expression )
        @expression = expression
      end

      include Operator

      def evaluate( state )
        @state = state
        @expression.visit( self )
      end

      def visit_constant( value )
        value
      end

      def visit_variable( name )
        @state.get_variable( name )
      end

      def visit_binary_operation( operator, left, right )
        case operator
        when PLUS then left + right
        when MINUS then left - right
        when TIMES then left * right
        when DIVIDED_BY then left / right
        when MODULO then left % right
        when POWER then left ** right
        when EQUAL then left == right
        when UNEQUAL then left != right
        when GREATER then left > right
        when GREATER_EQUAL then left >= right
        when SMALLER then left < right
        when SMALLER_EQUAL then left <= right
        when OR then left || right
        when XOR then left != right
        when AND then left && right
        when IMPLIES then !left || right
        when IS_IMPLIED then left || !right
        when EQUIVALENT then left == right
        else
          raise
        end
      end

      def visit_unary_operation( operator, inner )
        case operator
        when UNARY_PLUS then inner
        when UNARY_MINUS then -inner
        when NOT then !inner
        else
          raise
        end
      end

    end
    
  end
  
end
