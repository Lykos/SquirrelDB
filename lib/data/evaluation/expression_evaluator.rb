require 'ast/operator'
require 'ast/visitor'
require 'data/evaluation/expression_cost_calculator'

module SquirrelDB

  module Data
  
    class ExpressionEvaluator < AST::Visitor

      def initialize( expression )
        @expression = expression
      end

      include Operator

      # Evaluate this expression in the given state
      #
      def evaluate( state )
        @state = state
        @expression.visit( self )
      end
      
      def cost
        @cost ||= ExpressionCostCalculator.new(@expression).cost
      end

      def visit_constant( value, type )
        value
      end

      def visit_variable( name )
        @state[name]
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
          raise "Unknown operator #{operator}"
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
