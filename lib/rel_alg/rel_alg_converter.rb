require 'ast/projection'
require 'ast/selection'
require 'ast/visitor'

module SquirrelDB

  module RelAlg

    class RelAlgConverter < SQL::Visitor
      
      include SQL
      include RelAlg

      def process( statement )
        statement.visit( self )
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
          DualTable.new
        else
          until tables.length == 1
            tables.push( Cartesian.new( *tables.shift(2) ) )
          end
          tables[0]
        end
      end
      
      def visit_where_clause( expression )
        expression
      end

      def visit_binary_operation( binary_operation )
        # TODO The parser should do that
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

    end

  end

end
