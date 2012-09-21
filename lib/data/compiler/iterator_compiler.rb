require 'data/iterators/cartesian_iterator'
require 'data/iterators/memory_table_scanner'
require 'data/iterators/projector'
require 'data/iterators/selector'
require 'ast/scoped_variable'
require 'ast/variable'
require 'ast/selection'
require 'ast/projection'

module SquirrelDB

  module Data

    class IteratorCompiler
      
      include AST

      def process( statement )
        statement.visit( self )
      end

      def visit_renaming( expression, name )
        Renaming.new( expression, name )
      end

      def visit_binary_operation( operator, left, right )
        BinaryOperation.new( operator, left, right )
      end

      def visit_unary_operation( operator, inner )
        UnaryOperation.new( operator, inner )
      end

      def visit_function_application( function, parameters )
        FunctionApplication.new(
          function,
          parameters
        )
      end

      def visit_constant( value, type )
        Constant.new( value, type )
      end

      def visit_variable( name )
        Variable.new( name )
      end
      
      def visit_selection( expression, inner )
        Selector.new(
          expression,
          inner
        )
      end
      
      def visit_projection( columns, inner )
        Projector.new( columns, inner )
      end

      def visit_renaming( expression, name )
        Renaming.new( expression, name )
      end

    end

  end

end
