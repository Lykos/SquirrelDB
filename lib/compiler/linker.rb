require 'ast/iterators/memory_table_scanner'
require 'ast/iterators/inserter'
require 'ast/iterators/expression_evaluator'
require 'ast/visitors/transform_visitor'
require 'ast/common/column'

module SquirrelDB

  module Compiler

    class Linker
      
      include AST
      include TransformVisitor
      
      def initialize(tuple_wrapper, schema_manager, table_manager)
        @tuple_wrapper = tuple_wrapper
        @table_manager = table_manager
        @schema_manager = schema_manager
      end

      def process(statement)
        column_stack = []
        offset_stack = []
        ast = visit(statement, column_stack)
        raise InternalError, "Column Stack not empty." unless column_stack.empty?
        ast
      end
      
      include AST
      include TransformVisitor
      
      def visit_selection(selection, column_stack)
        inner = visit(selection.inner)
        Selector.new(
          ExpressionEvaluator.new(visit(selection.expression)),
          inner
        )
      end
      
      def visit_projection(projection, column_stack)
        Projector.new(
          projection.columns.collect { |c| ExpressionEvaluator.new(visit(c)) },
          visit(projection.inner)
        )
      end
      
      def visit_cartesian(cartesian, column_stack)
        CartesianIterator.new(
          visit(cartesian.left),
          visit(cartesian.right)
        )
      end
            
      def visit_pre_linked_table(pre_linked_table, column_stack)
        page_no = @table_manager.page_no(pre_linked_table.table_id)
        MemoryTableScanner.new(pre_linked_table.name, page_no, @tuple_wrapper, pre_linked_table.schema)
      end
      
      # TODO Do this differently
      def visit_create_table(create_table, column_stack)
        TableCreator.new(visit, column_stack)
      end
      
      def visit_insert(insert, column_stack)
        pre_linked_table = insert.variable
        page_no = @table_manager.page_no(pre_linked_table.table_id)
        name = pre_linked_table.name
        schema = pre_linked_table.schema
        table_columns = schema.columns # The columns of the table
        insert_columns = insert.columns # The columns we want to fill with new non-default values
        value_columns = insert.inner.schema.columns # How the columns of our values look like
        columns = table_columns.collect do |col|
          if index = insert_columns.find_index { |c| c.index == col.index }
            unless col.type == insert_columns[index].type && col.name == insert_columns[index].name
              raise "Incompatible columns insert_column: #{insert_columns[index].inspect} for table_column #{col.inspect}."
            end
            unless col.type == insert_columns[index].type
              raise "Incompatible columns insert_column: #{value_columns[index].inspect} for value_column #{col.inspect}."
            end
            value_columns[index] # TODO index is wrong in case of nested stuff
          else
            col.default
          end
        end
        inner = Projector.new(
          columns.map { |col| ExpressionEvaluator.new(col) },
          visit(insert.inner)
        )
        Inserter.new(name, page_no, @tuple_wrapper, schema, inner)
      end
      
    end

  end

end