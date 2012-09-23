require 'ast/common/operator'
require 'ast/visitors/visitor'
require 'data/evaluation/expression_cost_calculator'
require 'forwardable'

module SquirrelDB

  module Data
  
    class ExpressionEvaluator < AST::Visitor

      def initialize( expression )
        @expression = expression
      end

      extend Forwardable
      include AST
      
      def_delegators :@expression, :accept
      
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
        when Operator::PLUS then left + right
        when Operator::MINUS then left - right
        when Operator::TIMES then left * right
        when Operator::DIVIDED_BY then left / right
        when Operator::MODULO then left % right
        when Operator::POWER then left ** right
        when Operator::EQUAL then left == right
        when Operator::UNEQUAL then left != right
        when Operator::GREATER then left > right
        when Operator::GREATER_EQUAL then left >= right
        when Operator::SMALLER then left < right
        when Operator::SMALLER_EQUAL then left <= right
        when Operator::OR then left || right
        when Operator::XOR then left != right
        when Operator::AND then left && right
        when Operator::IMPLIES then !left || right
        when Operator::IS_IMPLIED then left || !right
        when Operator::EQUIVALENT then left == right
        else
          raise "Unknown operator #{operator}"
        end
      end

      def visit_unary_operation( operator, inner )
        case operator
        when Operator::UNARY_PLUS then inner
        when Operator::UNARY_MINUS then -inner
        when Operator::NOT then !inner
        else
          raise
        end
      end

    end
    
  end
  
end
