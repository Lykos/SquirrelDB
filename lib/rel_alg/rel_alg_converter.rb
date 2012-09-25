require 'ast/rel_alg_operators/all'
require 'ast/visitors/transform_visitor'

module SquirrelDB

  module RelAlg

    class RelAlgConverter < AST::TransformVisitor

      def process( statement )
        statement.accept( self )
      end

      def visit_select_statement( columns, tables, expression )
        Projection.new(
          columns,
          Selection.new(
            expression,
            tables
          )
        )
      end
      
      def visit_select_clause( expression )
        expression
      end
      
      def visit_from_clause( tables )
        if tables.empty?
          DummyTable.new
        else
          tables.reduce { |a, b| Cartesian.new(a, b) }
        end
      end
      
      def visit_where_clause( expression )
        expression
      end

      def visit_scoped_variable( scope, variable )
        if variable.kind_of?( FunctionApplication )
          FunctionApplication.new(
            ScopedVariable.new( left, right.function ),
            right.parameters
          )
        else
          super
        end
      end

    end

  end

end
