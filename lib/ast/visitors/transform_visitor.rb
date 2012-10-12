require 'ast/common/all'
require 'ast/rel_alg_operators/all'
require 'ast/iterators/all'
require 'ast/sql/all'
require 'ast/visitors/visitor'

module SquirrelDB

  module AST
    
    module TransformVisitor
      
      include Visitor
     
      def visit_select_statement(select_statement, *args)
        SelectStatement.new(
          visit(select_statement.select_clause, *args),
          visit(select_statement.from_clause, *args),
          visit(select_statement.where_clause, *args)
        )
      end
      
      def visit_dummy_table(dummy_table, *args)
        DummyTable.new(
          dummy_table.schema,
          dummy_table.tuple
        )
      end

      def visit_select_clause(select_clause, *args)
        SelectClause.new(select_clause.columns.collect { |c| visit(c) })
      end

      def visit_from_clause(from_clause, *args)
        FromClause.new(from_clause.tables.collect { |t| visit(t) })
      end
      
      def visit_where_clause(where_clause, *args)
        WhereClause.new(visit(where_clause.expression))
      end
      
      def visit_pre_linked_table(table, *args)
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
      
      def visit_projector(projector, *args)
        Projector.new(
          projector.column_evaluators.map { |ev| visit(ev, *args) },
          visit(projector.inner, *args)
        )
      end
      
      def visit_create_table(create_table, *args)
        CreateTable.new(
          visit(create_table.variable, *args),
          create_table.columns.collect { |column| visit(column, *args) }
        )
      end
      
      def visit_insert(insert)
        Insert.new(
          visit(insert.variable),
          insert.columns.collect { |column| visit(column) },
          visit(insert.inner)
        )
      end
      
      def visit_cartesian_iterator(cartesian_iterator)
        CartesianIterator.new(
          visit(cartesian_iterator.left),
          visit(cartesian_iterator.right)
        )
      end
      
      def visit_cartesian(cartesian)
        Cartesian.new(
          visit(cartesian.left),
          visit(cartesian.right)
        )
      end
      
      def visit_expression_evaluator(expression_evaluator, *args)
        ExpressionEvaluator.new(visit(expression_evaluator.expression, *args))
      end
      
      def visit_column(column, *args)
        Column.new(
          column.name,
          column.type,
          column.index,
          visit(column.default, *args)
        )
      end
      
      def visit_selection(selection, *args)
        Selection.new(
          visit(selection.expression, *args),
          visit(selection.inner, *args)
        )
      end
      
    end

  end
  
end