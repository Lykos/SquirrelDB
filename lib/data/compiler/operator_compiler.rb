require 'data/iterators/cartesian_iterator'
require 'data/iterators/memory_table_scanner'
require 'data/iterators/projector'
require 'data/iterators/selector'
require 'sql/elements/scoped_variable'
require 'sql/elements/variable'

module RubyDB

  module Data

    class OperatorCompiler

      def process( statement )
        statement.visit( self )
      end

      def visit_renaming( renaming )
        Renaming.new( renaming.expression.visit( self ), renaming.name )
      end

      def visit_binary_operation( binary_operation )
        left = binary_operation.left.visit( self )
        right = binary_operation.right.visit( self )
        if binary_operation.operator == Operator::DOT and right.kind_of?( FunctionApplication )
          FunctionApplication.new(
            ScopedVariable.new( left, right.function ),
            right.parameters
          )
        elsif binary_operation.operator == Operator::DOT
          ScopedVariable.new( left, right )
        else
          BinaryOperation.new( binary_operation.operator, left, right )
        end
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

      def visit_where_clause( expression )
        expression
      end

      def visit_from_clause( from_clause )
        from_clause.tables.collect { |t| t.visit( self ) }
      end

      def visit_renaming( expression )
        Renaming.new( expression, name )
      end

      def visit_cartesian( left, right )
        CartesianIterator.new( table( left ), table( right ) )
      end

      private

      def table( t )
        if t.kind_of?( Sql::ScopedVariable ) or t.kind_of( Sql::Variable )
          MemoryTableScanner.new( @table_manager.get_page_no( t ) )
        else
          t
        end
      end

    end

  end

end
