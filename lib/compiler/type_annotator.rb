require 'ast/sql/from_clause'
require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/column'
require 'ast/common/pre_linked_table'
require 'ast/common/renaming'
require 'ast/common/expression'
require 'ast/sql/values'
require 'ast/iterators/dummy_iterator'
require 'ast/visitors/transform_visitor'
require 'schema/expression_type'
require 'schema/schema'
require 'errors/name_error'
require 'errors/type_error'
require 'errors/internal_error'
require 'compiler/link_helper'

module SquirrelDB

  module Compiler

    # Creates the type annotations for the expressions
    # and the schemas for tables and raises errors in case of type errors or unresolvable symbols.
    class TypeAnnotator
      
      include AST
      include TransformVisitor
      include LinkHelper
            
      def initialize(schema_manager, function_manager, table_manager)
        @schema_manager = schema_manager
        @function_manager = function_manager
        @table_manager = table_manager
      end

      def process(statement)
        column_stack = [{}]
        ast = visit(statement, column_stack)
        raise InternalError, "Column Stack not empty." unless column_stack.length == 1
        ast
      end
      
      # Reads type information from the tables in the from clause.
      def visit_from_clause(from_clause, column_stack)
        tables = from_clause.tables.map do |c|
          if c.kind_of?(Renaming)
            raise InternalError, "#{c.expression.inspect} is not supported yet in a from clause." unless c.expression.variable?
            var = c.expression
            names = [c.name]
          elsif c.variable?
            var = c
            names = [c]
          else
            raise InternalError, "#{c.inspect} is not supported yet in a from clause."
          end
          if var.kind_of?(ScopedVariable)
            names << var.variable
          end
          raise NameError, "Table #{var} does not exist." unless @schema_manager.has?(var)
          schema = @schema_manager.get(var)
          each_link_info(names, schema) do |name, column|
            type = column.type.expression_type
            if column_stack.last.has_key?(name)
              column_stack.last[name] = :ambiguous
            else
              column_stack.last[name] = type
            end
          end
          PreLinkedTable.new(schema, names, @table_manager.variable_id(var))
        end
        FromClause.new(tables)
      end
      
      def visit_where_clause(where_clause, column_stack)
        expression = visit(where_clause.expression, column_stack)
        raise TypeError, "The expression of a where clause has to return a boolean value." unless expression.type == ExpressionType::BOOLEAN
        WhereClause.new(expression)
      end
  
      def type(variable, column_stack)
        if !column_stack.empty? && column_stack.last.has_key?(variable)
          raise NameError, "#{variable} is ambiguous." if column_stack.last[variable] == :ambiguous 
          column_stack.last[variable]
        else
          raise NameError, "Variable #{variable} cannot be resolved."
        end
      end
      
      def visit_variable(variable, column_stack)
        Variable.new(variable.name, type(variable, column_stack))
      end
      
      def visit_scoped_variable(scoped_variable, column_stack)
        ScopedVariable.new(scoped_variable.scope, scoped_variable.variable, type(scoped_variable, column_stack))
      end

      def visit_select_statement(select_statement, column_stack)
        column_stack << column_stack.last.dup
        from_clause = visit(select_statement.from_clause, column_stack)
        where_clause = visit(select_statement.where_clause, column_stack)
        select_clause = visit(select_statement.select_clause, column_stack)
        column_stack.pop
        SelectStatement.new(select_clause, from_clause, where_clause)
      end
      
      def visit_expression(expression, column_stack)
        if expression.is_a?(Expression)
          visit(expression, column_stack)
        elsif expression.is_a?(SelectStatement)
          select = visit(expression, column_stack)
          schema = select.schema
          if select.schema.length != 1
            raise TypeError, "A select statement inside an expression has to return exactly one column."
          end
          SelectExpression.new(select, schema.columns[0].type)
        else
          raise InternalError, "Unkown expression #{expression.inspect}."
        end
      end
      
      def visit_function_application(fun_app, column_stack)
        arguments = fun_app.arguments.map { |arg| visit_expression(arg, column_stack) } 
        f = @function_manager.function(fun_app.variable, arguments.map { |arg| arg.type })
        case f
        when :no_candidates then raise NameError, "Function #{fun_app.variable} cannot be resolved."
        when :none then raise TypeError, "Function #{fun_app.arguments} is not defined for types #{fun_app.arguments.collect { |t| t.to_s }.join(", ")}."
        when :ambiguous_fitting, :ambiguous_convertible then raise TypeError, "Function #{fun_app} is ambiguous for types #{fun_app.arguments.collect { |t| t.to_s }.join(", ")}}."
        else
          FunctionApplication.new(fun_app.variable, arguments, f.return_type)
        end
      end
      
      def visit_create_table(create_table, column_stack)
        raise NameError, "Table #{create_table.variable} exists." if @schema_manager.has?(create_table.variable)
        names = []
        columns = create_table.columns.collect do |c|
          if names.include? c.name
            raise NameError, "Column name #{c.name} appears more than once."
          end
          names << c.name
          visit(c, column_stack)
        end
        CreateTable.new(create_table.variable, columns)
      end
      
      def visit_column(column, column_stack)
        if column.has_default?
          default = visit(column.default)
          raise TypeError, "The default value of column #{column.name} has type #{default.type} which does not fit into a #{column.type}." unless column.type.converts_from?(default.type)
          Column.new(column.name, column.type, default)
        else
          column
        end
      end
      
      def visit_unary_operation(unop, column_stack)
        inner = visit_expression(unop.inner, column_stack)
        f = @function_manager.function(unop.operator, [inner.type])
        case f
        when :no_candidates then raise InternalError, "Invalid operator #{binop.operator}"
        when :none then raise TypeError, "No operator #{unop.operator} defined for types #{inner.type}."
        when :ambiguous_fitting, :ambiguous_convertible then raise TypeError, "Operator #{unop.operator} is ambiguous for types #{inner.type}."
        else
          UnaryOperation.new(unop.operator, inner, f.return_type)
        end
      end
      
      def visit_binary_operation(binop, column_stack)
        left = visit_expression(binop.left, column_stack)
        right = visit_expression(binop.right, column_stack)
        f = @function_manager.function(binop.operator, [left.type, right.type])
        case f
        when :no_candidates then raise InternalError, "Invalid operator #{binop.operator}"
        when :none then raise TypeError, "No operator #{binop.operator} defined for types #{left.type}, #{right.type}."
        when :ambiguous_fitting, :ambiguous_convertible  then raise TypeError, "Operator #{binop.operator} is ambiguous for types #{left.type}, #{right.type}."
        else
          BinaryOperation.new(binop.operator, left, right, f.return_type)
        end
      end
      
      def visit_values(values, column_stack)
        vals = values.expressions.collect { |v| visit_expression(v, column_stack) }
        types = vals.collect { |v, i| v.type }
        DummyIterator.new(types, vals)
      end
      
      def visit_insert(insert, column_stack)
        schema = @schema_manager.get(insert.variable)
        pre_linked_table = PreLinkedTable.new(schema, insert.variable.to_s, @table_manager.variable_id(insert.variable))
        columns = insert.columns.collect { |c| schema.column(c.name) }
        inner = visit(insert.inner, column_stack)
        if inner.length != columns.length
          raise TypeError, "Insert for #{columns.length} columns has #{inner.length} values."
        end
        columns.zip(inner.types).each do |arg|
          raise TypeError, "Value of type #{arg[1]} cannot be inserted into a column of type #{arg[0]}." unless arg[0].type.converts_from?(arg[1])
        end
        Insert.new(pre_linked_table, columns, inner)
      end
      
    end

  end

end
