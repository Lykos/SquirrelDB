require 'ast/projection'
require 'ast/selection'
require 'ast/binary_operation'
require 'ast/unary_operation'
require 'ast/operator'
require 'ast/constant'
require 'ast/function_application'
require 'ast/renaming'
require 'ast/select_clause'
require 'ast/from_clause'
require 'ast/where_clause'
require 'ast/select_statement'
require 'ast/wild_card'
require 'ast/visitor'

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

      def visit_from_clause( columns, tables, expression )
        tables = from_clause.tables.collect { |column| column.visit( self ) }
        if tables.empty?
          DualTable.new
        else
          until tables.length == 1
            tables.push( Cartesian.new( *tables.shift(2) ) )
          end
          tables[0]
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

      def visit_constant( constant )
        Constant.new( constant.value, constant.type )
      end

      def visit_variable( name )
        Variable.new( name )
      end

      def visit_renaming( expression, name )
        Renaming.new( expression, name )
      end
      
    end

  end
  
end