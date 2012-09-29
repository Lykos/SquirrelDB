require 'ast/sql/from_clause'
require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/column'
require 'ast/common/pre_linked_table'
require 'ast/common/renaming'
require 'ast/visitors/transform_visitor'
require 'schema/table_schema'

module SquirrelDB

  module RelAlg

    # TODO Move this into linker
    class StatefulPreLinker
      
      include AST
      include TransformVisitor
            
      def initialize(table_manager, schema_manager)
        @table_manager = table_manager
        @schema_manager = schema_manager
        @column_stack = []
        @offset_stack = []
        @used = false
      end

      def process(statement)
        raise "StatefulPreLinker can only be used once." if @used
        @used = true
        ast = visit(statement)
        raise "Column Stack not empty." unless @column_stack.empty?
        raise "Offset Stack not empty." unless @column_stack.empty?
        ast
      end

      def visit_from_clause(from_clause)
        # TODO Check for ambiguities
        columns = @column_stack.empty? ? {} : @column_stack.last.dup
        offset = @offset_stack.empty? ? 0 : @offset_stack.last
        tables = from_clause.tables.map do |c|
          if c.kind_of?(Renaming) && c.expression.is_variable?
            var = c.expression
            names = [c.name]
          elsif c.variable?
            var = c
            names = [c]
            if var.kind_of?(ScopedVariable)
              names.unshift(c.variable)
            end
          else
            var = nil
          end
          if var
            schema = @schema_manager.get(var)
            schema.each_column do |col|
              col_var = Variable.new(col.name)
              columns[col_var] = col
              names.each do |n|
                columns[ScopedVariable.new(n, col_var)] = col
              end
            end
            offset += schema.length
            PreLinkedTable.new(schema, names[0], @table_manager.variable_id(var))
          else
            c
          end
        end
        @column_stack << columns
        @offset_stack << offset
        FromClause.new(tables)
      end
      
      def unvisit_from_clause
        @column_stack.pop
        @offset_stack.pop
      end
  
      def visit_potential_column(variable)
        if !@column_stack.empty? && @column_stack.last.has_key?(variable)
          @column_stack.last[variable]
        else
          variable
        end
      end
      
      def visit_variable(variable)
        visit_potential_column(variable)
      end
      
      def visit_scoped_variable(scoped_variable)
        visit_potential_column(scoped_variable)
      end

      def visit_select_statement(select_statement)
        from_clause = visit(select_statement.from_clause)
        where_clause = visit(select_statement.where_clause)
        select_clause = visit(select_statement.select_clause)
        unvisit_from_clause
        SelectStatement.new(select_clause, from_clause, where_clause)
      end
      
      def visit_insert(insert)
        schema = @schema_manager.get(insert.variable)
        pre_linked_table = PreLinkedTable.new(schema, insert.variable.name, @table_manager.variable_id(insert.variable))
        cols = insert.columns.collect { |column| schema.column(column.name) }
        # TODO This is kind of terrible, change the semantic of dummy table and refactor
        inner = if insert.inner.kind_of?(Array)
          dummy_schema = Schema::TableSchema.new(insert.inner.collect.with_index { |v, i| Column.new(v.to_s, v.type, i) })
          values = insert.inner.collect { |v| v.value } # TODO only works for constants
          DummyTable.new(dummy_schema, Tuple.new(values))
        else
          visit(insert.inner)
        end
        Insert.new(pre_linked_table, cols, inner)
      end
      
    end

  end

end
