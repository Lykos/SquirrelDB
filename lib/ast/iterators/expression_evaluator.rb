require 'ast/common/operator'
require 'ast/visitors/visitor'
require 'ast/common/element'
require 'data/evaluation/expression_cost_calculator'
require 'forwardable'

module SquirrelDB

  module AST
  
    class ExpressionEvaluator < Element

      def initialize(expression)
        @expression = expression
      end

      extend Forwardable
      include AST
      include Visitor
      
      attr_reader :expression
            
      def_delegators :@expression, :type
      
      def ==(other)
        self.class == other.class && @expression == other.expression
      end
      
      def eql?(other)
        self == other
      end

      def to_s
        "ExpressionEvaluator(" + @expression.to_s + ")"
      end
      
      def inspect
        "ExpressionEvaluator(" + @expression.inspect + ")"
      end
      
      def hash
        [self.class, @expression].hash
      end
      
      # Evaluate this expression in the given state
      #
      def evaluate(state)
        @state = state
        visit(expression, state)
      end
      
      def visit_constant(constant, state)
        constant.value
      end

      def visit_scoped_variable(scoped_variable, state)
        # TODO
        raise "Unknown variable #{scoped_variable}"
      end

      def visit_variable(variable, state)
        # TODO
        raise "Unknown variable #{variable}"
      end

      def visit_binary_operation(binary_operation, state)
        operator = binary_operation.operator
        left = visit(binary_operation.left, state)
        right = visit(binary_operation.right, state)
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

      def visit_unary_operation(unary_operation, state)
        operator = unary_operation.operator
        visit(unary_operation.inner)
        case operator
        when Operator::UNARY_PLUS then inner
        when Operator::UNARY_MINUS then -inner
        when Operator::NOT then !inner
        else
          raise
        end
      end
      
      def visit_column(column, state)
        @state[column.index]
      end

    end
    
  end
  
end
