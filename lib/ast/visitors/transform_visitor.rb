require 'ast/common/all'
require 'ast/rel_alg_operators/all'
require 'ast/iterators/all'
require 'ast/sql/all'
require 'ast/visitors/visitor'

module SquirrelDB

  module AST
    
    module TransformVisitor
      
      include Visitor
     
      def visit_select_statement(select_statement)
        SelectStatement.new(
          visit(select_statement.select_clause),
          visit(select_statement.from_clause),
          visit(select_statement.where_clause)
        )
      end
      
      def visit_dummy_table(dummy_table)
        DummyTable.new(
          dummy_table.schema,
          dummy_table.tuple
        )
      end

      def visit_select_clause(select_clause)
        SelectClause.new(select_clause.columns.collect { |c| visit(c) })
      end

      def visit_from_clause(from_clause)
        FromClause.new(from_clause.tables.collect { |t| visit(t) })
      end
      
      def visit_where_clause(where_clause)
        WhereClause.new(visit(where_clause.expression))
      end
      
      def visit_pre_linked_table(table)
        PreLinkedTable.new(table.schema, table.name, table.table_id)
      end

      def visit_from_clause( columns, tables, expression )
        tables = from_clause.tables.collect { |column| column.visit( self ) }
        if tables.empty?
          FromClause.new(DualTable.new)
        else
          FromClause.new(tables.reduce { |a, b| Cartesian.new(a, b) })
        end
      end
      
      def visit_wild_card(wild_card)
        wild_card
      end

      def visit_renaming(renaming)
        Renaming.new(visit(renaming.expression), renaming.name)
      end

      def visit_binary_operation(binary_operation)
        BinaryOperation.new(
          binary_operation.operator,
          visit(binary_operation.left),
          visit(binary_operation.right)
        )
      end

      def visit_unary_operation( unary_operation )
        UnaryOperation.new(
          unary_operation.operator,
          visit(unary_operation.inner)
        )
      end

      def visit_function_application(function_application)
        FunctionApplication.new(
          visit(function_application.function),
          function_application.parameters.collect { |parameter| visit( parameter ) }
        )
      end

      def visit_constant(constant)
        constant
      end

      def visit_scoped_variable(scoped_variable)
        ScopedVariable.new(
          visit(scoped_variable.scope),
          visit(scoped_variable.variable)
        )
      end

      def visit_variable(variable)
        variable
      end
      
      def visit_selector(selector)
        Selector.new(
          visit(selector.expression_evaluator),
          visit(selector.inner)
        )
      end
      
      def visit_projector(projector)
        Projector.new(
          projector.column_evaluators.map { |ev| visit(ev) },
          visit(projector.inner)
        )
      end
      
      def visit_create_table(create_table)
        CreateTable.new(
          visit(create_table.variable),
          create_table.columns.collect { |column| visit(column) }
        )
      end
      
      def visit_insert(insert)
        Insert.new(
          visit(insert.variable),
          insert.columns.collect { |column| visit(column) },
          visit(insert.inner)
        )
      end
      
      def visit_expression_evaluator(expression_evaluator)
        ExpressionEvaluator.new(visit(expression_evaluator.expression))
      end
      
      def visit_column(column)
        Column.new(
          column.name,
          column.type,
          column.index,
          visit(column.default)
        )
      end
      
      def visit_selection(selection)
        Selection.new(
          visit(selection.expression),
          visit(selection.inner)
        )
      end
      
    end

  end
  
end