require 'sql/elements/projection'
require 'sql/elements/selection'
require 'sql/elements/operator'
require 'sql/elements/constant'
require 'sql/elements/variable'
require 'sql/parser/syntactic_parser'

module RubyDB

  module Sql

    class RelAlgConverter

      def initialize( parser=SyntacticParser.new )
        @parser = parser
      end

      def compile( string )
        select_statement = @parser.parse( string )
        select_statement.visit( self )
      end

      def visit_select_statement( select_statement )
        Projection.new(
          select_statement.select_clause.visit( self ),
          Selection.new(
            select_statement.where_clause.visit( self ),
            select_statement.from_clause.visit( self )
          )
        )
      end

      def visit_select_clause( select_clause )
        select_clause.columns.collect { |table| table.visit( self ) }
      end

      def visit_table( table )
        Table.new( table.expression.visit( self ), table.name )
      end

      def visit_where_clause( where_clause )
        where_clause.expression.visit( self )
      end

      def visit_from_clause( from_clause )
        tables = from_clause.tables.collect { |column| column.visit( self ) }
        if tables.empty?
          return Renaming.new( "dual", "dual" )
        else
          until tables.length == 1
            tables.push( Cartesian.new( *tables.shift(2) ) )
          end
          tables[0]
        end
      end

      def visit_column( column )
        Renaming.new( column.expression.visit( self ), column.name )
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
        Constant.new( constant.name )
      end

      def visit_variable( variable )
        Variable.new( variable.name )
      end

      def visit_where_clause( where_clause )
        where_clause.expression.visit( self )
      end

      def visit_from_clause( from_clause )
        from_clause.collect { |t| t.visit( self ) }
      end

      def visit_renaming( renaming )
        Renaming.new( renaming.expression.visit( self ), renaming.name.visit( self ) )
      end

    end

  end

end
