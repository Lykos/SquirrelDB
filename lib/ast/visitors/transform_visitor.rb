require 'ast/common/all'
require 'ast/rel_alg_operators/all'
require 'ast/iterators/all'
require 'ast/sql/all'
require 'ast/visitors/visitor'

module SquirrelDB

  module AST
    
    class TransformVisitor < Visitor
     
      def visit_select_statement( select_clause, from_clause, where_clause )
        SelectStatement.new(
          select_clause,
          from_clause,
          where_clause
        )
      end

      def visit_select_clause( columns )
        SelectClause.new( columns )
      end

      def visit_from_clause( tables )
        FromClause.new( tables )
      end
      
      def visit_where_clause( expression )
        expression
      end
      
      def visit_pre_linked_table(schema, name, table_id, read_only)
        PreLinkedTable.new(schema, name, table_id, read_only)
      end

      def visit_from_clause( columns, tables, expression )
        tables = from_clause.tables.collect { |column| column.visit( self ) }
        if tables.empty?
          FromClause.new(DualTable.new)
        else
          FromClause.new(tables.reduce { |a, b| Cartesian.new(a, b) })
        end
      end
      
      def visit_wild_card( wild_card )
        wild_card
      end

      def visit_renaming( renaming, variable )
        Renaming.new( rexpression, variable )
      end

      def visit_binary_operation( operator, left, right )
        BinaryOperation.new( operator, left, right )
      end

      def visit_unary_operation( unary_operation )
        UnaryOperation.new( unary_operation.operator, unary_operation.visit( self ) )
      end

      def visit_function_application( function_application )
        FunctionApplication.new(
          function_application.function,
          function_application.parameters.collect { |param| param.visit( self ) }
        )
      end

      def visit_constant( value, type )
        Constant.new( value, type )
      end

      def visit_scoped_variable( scope, variable )
        ScopedVariable.new( scope, variable )
      end

      def visit_variable( name )
        Variable.new( name )
      end

      def visit_renaming( expression, name )
        Renaming.new( expression, name )
      end
      
      def visit_selector( expression, inner )
        Selector.new( expression, inner )
      end
      
      def visit_projector( renamings, inner )
        Projector.new( renamings, inner )
      end
      
      def visit_create_table( name, columns )
        CreateTable.new( name, columns )
      end
      
      def visit_insert( name, columns, values )
        Insert.new( name, columns, values )
      end
      
      def visit_tuple( values )
        Tuple.new( values )
      end
      
    end

  end
  
end