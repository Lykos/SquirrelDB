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
      
      def visit_dummy_iterator(dummy_iterator, *args)
        DummyIterator.new(
          dummy_iterator.types,
          dummy_iterator.expression_evaluators
        )
      end

      def visit_select_clause(select_clause, *args)
        SelectClause.new(select_clause.columns.collect { |c| visit(c, *args) })
      end

      def visit_from_clause(from_clause, *args)
        FromClause.new(from_clause.tables.collect { |t| visit(t, *args) })
      end
      
      def visit_where_clause(where_clause, *args)
        WhereClause.new(visit(where_clause.expression, *args))
      end
      
      def visit_pre_linked_table(table, *args)
        PreLinkedTable.new(table.schema, table.names, table.table_id)
      end

      def visit_from_clause(from_clause, *args)
        tables = from_clause.tables.collect { |column| column.visit(self, *args) }
        FromClause.new(tables)
      end
      
      def visit_wild_card(wild_card, *args)
        wild_card
      end

      def visit_renaming(renaming, *args)
        Renaming.new(visit(renaming.expression, *args), visit(renaming.name, *args))
      end

      def visit_binary_operation(binary_operation, *args)
        BinaryOperation.new(
          binary_operation.operator,
          visit(binary_operation.left, *args),
          visit(binary_operation.right, *args)
        )
      end

      def visit_unary_operation(unary_operation, *args)
        UnaryOperation.new(
          unary_operation.operator,
          visit(unary_operation.inner, *args)
        )
      end

      def visit_function_application(function_application, *args)
        FunctionApplication.new(
          visit(function_application.variable, *args),
          function_application.arguments.collect { |arg| visit(arg, *args) }
        )
      end

      def visit_constant(constant, *args)
        constant
      end

      def visit_scoped_variable(scoped_variable, *args)
        ScopedVariable.new(
          visit(scoped_variable.scope, *args),
          visit(scoped_variable.variable, *args)
        )
      end

      def visit_variable(variable, *args)
        variable
      end
      
      def visit_selector(selector, *args)
        Selector.new(
          visit(selector.expression_evaluator, *args),
          visit(selector.inner, *args)
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
      
      def visit_insert(insert, *args)
        Insert.new(
          visit(insert.variable, *args),
          insert.columns.collect { |column| visit(column, *args) },
          visit(insert.inner, *args)
        )
      end
      
      def visit_cartesian_iterator(cartesian_iterator, *args)
        CartesianIterator.new(
          visit(cartesian_iterator.left, *args),
          visit(cartesian_iterator.right, *args)
        )
      end
      
      def visit_cartesian(cartesian, *args)
        Cartesian.new(
          visit(cartesian.left, *args),
          visit(cartesian.right, *args)
        )
      end
      
      def visit_expression_evaluator(expression_evaluator, *args)
        ExpressionEvaluator.new(visit(expression_evaluator.expression, *args))
      end
      
      def visit_column(column, *args)
        if column.has_default?
          Column.new(
            column.name,
            column.type,
            visit(column.default, *args)
          )
        else
          column
        end
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