require 'ast/sql/from_clause'
require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/column'
require 'ast/common/pre_linked_table'
require 'ast/common/renaming'
require 'ast/common/expression'
require 'ast/iterators/dummy_iterator'
require 'ast/visitors/transform_visitor'
require 'schema/table_schema'
require 'schema/function'
require 'errors/symbol_error'
require 'errors/type_error'

module SquirrelDB

  module RelAlg

    # Creates the type annotations for the expressions
    # and the schemas for tables and raises errors in case of type errors or unresolvable symbols.
    class TypeAnnotator
      
      include AST
      include TransformVisitor
            
      def initialize(table_manager, schema_manager)
        @table_manager = table_manager
        @schema_manager = schema_manager
        @column_stack = []
        @used = false
      end

      def process(statement)
        raise "StatefulPreLinker can only be used once." if @used
        @used = true
        ast = visit(statement)
        raise "Column Stack not empty." unless @column_stack.empty?
        ast
      end

      # Reads type information from the tables in the from clause.
      def visit_from_clause(from_clause)
        # TODO Check for ambiguities
        columns = @column_stack.empty? ? {} : @column_stack.last.dup
        tables = from_clause.tables.map do |c|
          if c.kind_of?(Renaming) && c.expression.is_variable?
            var = c.expression
            names = [c.name]
          elsif c.variable?
            var = c
            names = [c]
            if var.kind_of?(ScopedVariable)
              names << c.variable
            end
          else
            var = nil
          end
          if var
            schema = @schema_manager.get(var)
            schema.each_column do |col|
              col_var = Variable.new(col.name)
              columns[col_var] = col.type
              names.each do |n|
                columns[ScopedVariable.new(n, col_var)] = col.type
              end
            end
            offset += schema.length
            PreLinkedTable.new(schema, names[0], @table_manager.variable_id(var))
          else
            c
          end
        end
        @column_stack << columns
        FromClause.new(tables)
      end
      
      def unvisit_from_clause
        @column_stack.pop
      end
  
      def type(variable)
        if !@column_stack.empty? && @column_stack.last.has_key?(variable)
          @column_stack.last[variable]
        else
          raise SymbolError, "Variable #{variable} cannot be resolved."
        end
      end
      
      def visit_variable(variable)
        Variable.new(variable.name, type(variable))
      end
      
      def visit_scoped_variable(scoped_variable)
        ScopedVariable.new(scoped_variable.scope, scoped_variable.variable, type(scoped_variable))
      end

      def visit_select_statement(select_statement)
        from_clause = visit(select_statement.from_clause)
        where_clause = visit(select_statement.where_clause)
        select_clause = visit(select_statement.select_clause)
        unvisit_from_clause
        SelectStatement.new(select_clause, from_clause, where_clause)
      end
      
      def visit_expression(expression)
        if expression.is_a?(Expression)
          visit(expression)
        elsif expression.is_a?(SelectStatement)
          select = visit(expression)
          schema = select.schema
          if select.schema.length != 1
            raise TypeError, "A select statement inside an expression has to return exactly one column."
          end
          SelectExpression.new(select, schema.columns[0].type)
        else
          raise InternalError, "Unkown expression #{expression.inspect}."
        end
      end
      
      def visit_function_application(fun_app)
        arguments = fun_app.arguments.map { |arg| visit_expression(arg) } 
        f = Function.function(fun_app.variable, arguments)
        case f
        when :no_candidates then raise SymbolError, "Function #{fun_app.variable} cannot be resolved."
        when :none then raise TypeError, "Function #{fun_app.arguments} is not defined for types #{fun_app.arguments.collect { |t| t.to_s }.join(", ")}."
        when :ambiguous then raise TypeError, "Function #{fun_app} is ambiguous for types #{fun_app.arguments.collect { |t| t.to_s }.join(", ")}}."
        else
          FunctionApplication.new(fun_app.variable, arguments)
        end
      end
      
      def visit_unary_operation(unop)
        inner = visit_expression(unop.inner)
        f = Function.function(unop.operator, [inner.type])
        case f
        when :no_candidates then raise InternalError, "Invalid operator #{binop.operator}"
        when :none then raise TypeError, "No operator #{unop.operator} defined for types #{inner.type}."
        when :ambiguous then raise TypeError, "Operator #{unop.operator} is ambiguous for types #{inner.type}."
        else
          UnaryOperation.new(unop.operator, inner, f.type)
        end
      end
      
      def visit_binary_operation(binop)
        left = visit_expression(binop.left)
        right = visit_expression(binop.right)
        f = Function.function(binop.operator, [left.type, right.type])
        case f
        when :no_candidates then raise InternalError, "Invalid operator #{binop.operator}"
        when :none then raise TypeError, "No operator #{binop.operator} defined for types #{left.type}, #{right.type}."
        when :ambiguous then raise TypeError, "Operator #{binop.operator} is ambiguous for types #{left.type}, #{right.type}."
        else
          BinaryOperation.new(binop.operator, left, right, f.type)
        end
      end
      
      def visit_insert(insert)
        schema = @schema_manager.get(insert.variable)
        pre_linked_table = PreLinkedTable.new(schema, insert.variable.name, @table_manager.variable_id(insert.variable))
        cols = insert.columns.collect { |col| visit(col) }
        inner = if insert.inner.kind_of?(Array)
          dummy_schema = Schema::TableSchema.new(insert.inner.collect { |v, i| Column.new(v.to_s, v.type) })
          values = insert.inner.collect { |v| visit_expression(v) }
          DummyIterator.new(dummy_schema, values)
        else
          visit(insert.inner)
        end
        Insert.new(pre_linked_table, cols, inner)
      end
      
    end

  end

end
