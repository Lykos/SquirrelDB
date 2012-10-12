require 'ast/iterators/rel_alg_iterator'
require 'ast/common/column'
require 'ast/common/constant'
require 'schema/table_schema'
require 'schema/expression_type'
require 'errors/no_rows'
require 'errors/too_many_rows'

module SquirrelDB

  module AST

    class ExpressionEvaluator < Element
            
      def initialize(expression)
        @expression = expression
      end
      
      attr_reader :expression
      
      def type
        @expression.type
      end
      
      def hash
        @hash ||= [super, @tuple].hash
      end
      
      def to_s
        "ExpressionEvaluator( " + @expression.to_s + " )"
      end
      
      def inspect
        "ExpressionEvaluator( " + @expression.to_s + " )"
      end
      
      def visit_linked_function_application(fun_app, state)
        args = fun_app.arguments.collect { |arg| visit(arg) }
        fun_app.call(*args)
      end
      
      def visit_constant(constant, state)
        constant.value
      end
      
      def visit_select_expression(select_expression, state)
        select = select_expression.select_statement
        select.open(state)
        value = select.next_item
        raise NoRows unless value
        raise TooManyRows if select.next_item
        value
      end

      def evaluate(state)
        visit(expression, state)
      end
      
    end

  end
  
end
