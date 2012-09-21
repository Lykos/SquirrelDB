require 'rel_alg/elements/projection'
require 'rel_alg/elements/selection'
require 'sql/elements/binary_operation'
require 'sql/elements/unary_operation'
require 'sql/elements/operator'
require 'sql/elements/constant'
require 'sql/elements/function_application'
require 'sql/elements/renaming'
require 'sql/elements/select_clause'
require 'sql/elements/from_clause'
require 'sql/elements/where_clause'
require 'sql/elements/select_statement'
require 'sql/elements/wild_card'

module SquirrelDB

  module Sql
    
    class Visitor
     
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
      
      def method_missing(name, *args)
        if name.to_s =~ /^visit_/
          raise RuntimeError, "Unknown visitor operation #{name}."
        else
          super
        end
      end
      
    end

  end
  
end