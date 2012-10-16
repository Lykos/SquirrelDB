require 'ast/iterators/all'
require 'ast/visitors/transform_visitor'
require 'ast/common/linked_variable'
require 'ast/common/linked_function_application'
require 'errors/compiler_error'
require 'compiler/link_helper'

module SquirrelDB

  module Compiler

    class Linker
      
      include AST
      include TransformVisitor
      include LinkHelper
      
      def initialize(tuple_wrapper, schema_manager, function_manager, table_manager)
        @tuple_wrapper = tuple_wrapper
        @table_manager = table_manager
        @function_manager = function_manager
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
        inner = visit(selection.inner, column_stack, offset_stack)
        Selector.new(
          ExpressionEvaluator.new(visit(selection.expression, column_stack, offset_stack)),
          inner
        )
      end
      
      def visit_dummy_iterator(dummy_iterator, column_stack, offset_stack)
        expression_evaluators = dummy_iterator.expression_evaluators.collect do |e|
          ExpressionEvaluator.new(visit(e, column_stack, offset_stack))
        end
        DummyIterator.new(dummy_iterator.types, expression_evaluators)
      end
      
      def visit_select_expression(select, column_stack, offset_stack)
        offset_stack << offset_stack.last
        column_stack << column_stack.last.dup
        super
        column_stack.pop
        offset_stack.pop        
      end
      
      def link_variable(variable, column_stack, offset_stack)
        raise CompilerError, "Unresolved variable #{variable}." unless column_stack.last.has_key?(variable)
        LinkedVariable.new(variable, column_stack.last[variable], variable.type)
      end
      
      alias visit_scoped_variable link_variable
      alias visit_variable link_variable
      
      def visit_projection(projection, column_stack, offset_stack)
        inner = visit(projection.inner, column_stack, offset_stack)
        Projector.new(
          projection.columns.collect { |c| ExpressionEvaluator.new(visit(c, column_stack, offset_stack)) },
          inner
        )
      end
      
      def visit_function_application(fun_app, column_stack, offset_stack)
        arguments = fun_app.arguments.map { |arg| visit(arg, column_stack, offset_stack) } 
        f = @function_manager.function(fun_app.variable, arguments.map { |arg| arg.type })
        raise CompilerError, "Function #{fun_app.variable} not found." unless f.kind_of?(Function)
        LinkedFunctionApplication.new(fun_app.variable, f.proc, arguments, f.return_type)
      end
      
      def visit_unary_operation(unop, column_stack, offset_stack)
        inner = visit(unop.inner, column_stack, offset_stack)
        f = @function_manager.function(unop.operator, [inner.type])
        raise CompilerError, "Function #{fun_app.variable} not found." unless f.kind_of?(Function)
        LinkedFunctionApplication.new(unop.operator, f.proc, [inner], f.return_type)
      end
      
      def visit_binary_operation(binop, column_stack, offset_stack)
        left = visit(binop.left, column_stack, offset_stack)
        right = visit(binop.right, column_stack, offset_stack)
        f = @function_manager.function(binop.operator, [left.type, right.type])
        raise CompilerError, "Function #{fun_app.variable} not found." unless f.kind_of?(Function)
        LinkedFunctionApplication.new(binop.operator, f.proc, [left, right], f.return_type)
      end
      
      def visit_cartesian(cartesian, column_stack, offset_stack)
        left = visit(cartesian.left, column_stack, offset_stack)
        right = visit(cartesian.right, column_stack, offset_stack)
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
        each_link_info(names, schema) do |name, col, i|
          column_stack.last[name.typed(col.type.expression_type)] = offset_stack.last + i
        end
        offset_stack[-1] += schema.length
        MemoryTableScanner.new(names[0], page_no, @tuple_wrapper, schema)
      end
      
      def visit_create_table(create_table, column_stack, offset_stack)
        TableCreator.new(create_table.variable, Schema::Schema.new(create_table.columns), @schema_manager)
      end
      
      def visit_insert(insert, column_stack, offset_stack)
        inner = visit(insert.inner, column_stack, offset_stack)
        pre_linked_table = insert.variable
        page_no = @table_manager.page_no(pre_linked_table.table_id)
        name = pre_linked_table.names[0].to_s
        schema = pre_linked_table.schema
        table_columns = schema.columns # The columns of the table
        insert_columns = insert.columns # The columns we want to fill with new non-default values
        columns = table_columns.collect.with_index do |col, i|
          if index = insert_columns.find_index { |c| c.name == col.name }
            LinkedVariable.new("column #{index}", offset_stack[-2].to_i + index, col.type.expression_type)
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