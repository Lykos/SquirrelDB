require 'ast/iterators/rel_alg_iterator'
require 'ast/common/column'
require 'ast/common/constant'
require 'schema/schema'
require 'schema/expression_type'
require 'errors/no_rows_error'
require 'errors/too_many_rows_error'
require 'ast/visitors/visitor'

module SquirrelDB

  module AST

    class ExpressionEvaluator < Element
      
      include Visitor
            
      def initialize(expression)
        @expression = expression
      end
      
      attr_reader :expression
      
      def type
        @type ||= @expression.type
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
        args = fun_app.arguments.collect { |arg| visit(arg, state) }
        fun_app.call(*args)
      end
      
      def visit_constant(constant, state)
        constant.value
      end
      
      def visit_linked_variable(linked_variable, state)
        state[linked_variable.offset]
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
