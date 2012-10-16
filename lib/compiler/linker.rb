require 'ast/iterators/memory_table_scanner'
require 'ast/iterators/inserter'
require 'ast/iterators/expression_evaluator'
require 'ast/visitors/transform_visitor'
require 'ast/common/column'
require 'compiler/link_helper'

module SquirrelDB

  module Compiler

    class Linker
      
      include AST
      include TransformVisitor
      include LinkHelper
      
      def initialize(tuple_wrapper, schema_manager, table_manager)
        @tuple_wrapper = tuple_wrapper
        @table_manager = table_manager
        @schema_manager = schema_manager
      end

      def process(statement)
        column_stack = [{}]
        offset_stack = [0]
        ast = visit(statement, column_stack, offset_stack)
        raise InternalError, "Column Stack not empty." unless column_stack.length == 1
        raise InternalError, "Offset Stack not empty." unless offset_stack.length == 1
        ast
      end
      
      include AST
      include TransformVisitor
      
      def visit_selection(selection, column_stack, offset_stack)
        inner = visit(selection.inner)
        Selector.new(
          ExpressionEvaluator.new(visit(selection.expression, column_stack, offset_stack)),
          inner
        )
      end
      
      def visit_select_expression(select, column_stack, offset_stack)
        offset_stack << offset_stack.last
        column_stack << column_stack.last.dup
        super
        column_stack.pop
        offset_stack.pop        
      end
      
      def link_variable(variable, column_stack, offset_stack)
        raise InternalError, "Unresolved variable #{variable}." unless column_stack.last.hast_key?(variable)
        LinkedVariable.new(variable, column_stack.last[variable])
      end
      
      alias visit_scoped_variable link_variable
      alias visit_variable link_variable
      
      # TODO Problems with nested projections, if things that are used outside get projected away.
      def visit_projection(projection, column_stack, offset_stack)
        inner = visit(projection.inner, collumn_stack, offset_stack)
        Projector.new(
          projection.columns.collect { |c| ExpressionEvaluator.new(visit(c, column_stack, offset_stack)) },
          inner
        )
      end
      
      def visit_cartesian(cartesian, column_stack, offset_stack)
        left = visit(cartesian.left, column_stack)
        right = visit(cartesian.right, column_stack)
        CartesianIterator.new(
          left,
          right
        )
      end
            
      def visit_pre_linked_table(pre_linked_table, column_stack, offset_stack)
        page_no = @table_manager.page_no(pre_linked_table.table_id)
        names = pre_linked_table.names
        schema = pre_linked_table.schema
        # Add the link info of this table
        each_link_info.with_index(names, schema) do |name, col, i|
          column_stack.last[name] = offset_stack.last
          offset_stack.last += 1
        end
        MemoryTableScanner.new(names[0], page_no, @tuple_wrapper, schema)
      end
      
      def visit_create_table(create_table, column_stack, offset_stack)
        TableCreator.new(visit, column_stack)
      end
      
      def visit_insert(insert, column_stack, offset_stack)
        # TODO Finish this
        inner = visit(insert.inner)
        pre_linked_table = insert.variable
        page_no = @table_manager.page_no(pre_linked_table.table_id)
        name = pre_linked_table.name
        schema = pre_linked_table.schema
        table_columns = schema.columns # The columns of the table
        insert_columns = insert.columns # The columns we want to fill with new non-default values
        columns = table_columns.collect.with_index do |col, i|
          if index = insert_columns.find_index { |c| c.name == col.name }
            LinkedVariable.new("column #{index}", offset_stack[-2].to_i + index)
          else
            col.default
          end # if
        end # collect
        inner = Projector.new(
          columns.map { |col| ExpressionEvaluator.new(col) },
          inner
        )
        Inserter.new(name, page_no, @tuple_wrapper, schema, inner)
      end
      
    end

  end

end