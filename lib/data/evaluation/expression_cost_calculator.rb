require 'ast/common/operator'
require 'ast/visitors/visitor'

module SquirrelDB

  module Data
  
    class ExpressionCostCalculator < AST::Visitor

      def initialize( expression )
        @expression = expression
      end

      include AST

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
        when Operator::PLUS then left + right + 1
        when Operator::MINUS then left + right + 1
        when Operator::TIMES then left + right + 2
        when Operator::DIVIDED_BY then left + right + 3
        when Operator::MODULO then left + right + 3
        when Operator::POWER then left + right + 5
        when Operator::EQUAL then left + right + 1
        when Operator::UNEQUAL then left + right + 1
        when Operator::GREATER then left + right + 1
        when Operator::GREATER_EQUAL then left + right + 1
        when Operator::SMALLER then left + right + 1
        when Operator::SMALLER_EQUAL then left + right + 1
        when Operator::OR then left + right + 1
        when Operator::XOR then left + right + 1
        when Operator::AND then left + right + 1
        when Operator::IMPLIES then left + right + 1
        when Operator::IS_IMPLIED then left + right + 1
        when Operator::EQUIVALENT then left + right + 1
        else
          raise "Unknown operator #{operator}"
        end
      end

      def visit_unary_operation( operator, inner )
        case operator
        when Operator::UNARY_PLUS then inner + 1
        when Operator::UNARY_MINUS then inner + 1
        when Operator::NOT then inner + 1
        else
          raise
        end
      end
     
    end
    
  end
  
end
