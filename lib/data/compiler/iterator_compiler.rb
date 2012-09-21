require 'data/iterators/cartesian_iterator'
require 'data/iterators/memory_table_scanner'
require 'data/iterators/projector'
require 'data/iterators/selector'
require 'sql/elements/scoped_variable'
require 'sql/elements/variable'
require 'rel_alg/elements/selection'
require 'rel_alg/elements/projection'
require 'data/compiler/unlinked_table'

module RubyDB

  module Data

    class IteratorCompiler
      
      include RelAlg
      include SQL

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

      private

      def table( t )
        if t.kind_of?( Sql::ScopedVariable ) or t.kind_of( Sql::Variable )
          UnlinkedTable.new( @table_manager.get_page_no( t ) )
        else
          t
        end
      end

    end

  end

end
