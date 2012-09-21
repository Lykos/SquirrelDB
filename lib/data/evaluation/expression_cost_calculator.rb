require 'sql/elements/operator'

module RubyDB

  module Data
  
    class ExpressionCostCalculator

      def initialize( expression )
        @expression = expression
      end

      include Operator

      # Evaluate this expression in the given state
      #
      def cost( state )
        @expression.visit( self )
      end

      def visit_constant( value, type )
        1
      end

      def visit_variable( name )
        2
      end

      def visit_binary_operation( operator, left, right )
        case operator
        when PLUS then left + right + 1
        when MINUS then left + right + 1
        when TIMES then left + right + 2
        when DIVIDED_BY then left + right + 3
        when MODULO then left + right + 3
        when POWER then left + right + 5
        when EQUAL then left + right + 1
        when UNEQUAL then left + right + 1
        when GREATER then left + right + 1
        when GREATER_EQUAL then left + right + 1
        when SMALLER then left + right + 1
        when SMALLER_EQUAL then left + right + 1
        when OR then left + right + 1
        when XOR then left + right + 1
        when AND then left + right + 1
        when IMPLIES then left + right + 1
        when IS_IMPLIED then left + right + 1
        when EQUIVALENT then left + right + 1
        else
          raise "Unknown operator #{operator}"
        end
      end

      def visit_unary_operation( operator, inner )
        case operator
        when UNARY_PLUS then inner + 1
        when UNARY_MINUS then inner + 1
        when NOT then inner + 1
        else
          raise
        end
      end
     
    end
    
  end
  
end
