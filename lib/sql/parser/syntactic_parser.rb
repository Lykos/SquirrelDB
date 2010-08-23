require 'syntax'
require 'operators'
require 'operator'
require 'expression'
require 'constant'
require 'function'
require 'eregex'
require 'lexical_parser'

module Sql

  class SyntacticParser

    def initialize( lexical_parser=LexicalParser.new )
      @lexical_parser = lexical_parser
    end

    include Syntax

    def parse( string )
      @tokens = @lexical_parser.parse( string )
      if @tokens[0] =~ SELECT
        parse_select( 0 )
      elsif @tokens[0] =~ INSERT
        parse_insert( 0 )
      elsif @tokens[0] =~ UPDATE
        parse_update( 0 )
      elsif @tokens[0] =~ DELETE
        parse_delete( 0 )
      elsif @tokens[0] =~ GRANT
        parse_grant( 0 )
      elsif @tokens[0] =~ CREATE
        parse_create( 0 )
      elsif @tokens[0] =~ DROP
        parse_drop( 0 )
      elsif @tokens[0] =~ ALTER
        parse_alter( 0 )
      elsif @tokens[0] =~ TRUNCATE
        parse_truncate( 0 )
      else
        raise
      end
    end

    def parse_select( start_index )
      select_clause, after_index = parse_select_clause( start_index )
      from_clause, after_index = parse_from( after_index )
      where_clause, after_index = parse_where( after_index )
      SelectStatement.new(select_clause, from_clause, where_clause)
    end

    def parse_from( start_index )
      return FromClause.new( [Tables::DUAL] ) unless @tokens[start_index] =~ FROM
      after_index = start_index + 1
      table, after_index = parse_table( after_index )
      tables = [table]
      until @tokens[after_index] =~ WHERE || !@tokens[after_index]
        table, after_index = parse_table( after_index)
        tables.push( table )
      end
      [table, after_index]
    end

    def parse_table( start_index )
      if @tokens[start_index] =~ PARENTHESE_OPEN
        table, after_index = parse_select( start_index + 1 )
        raise unless @tokens[after_index] =~ PARENTHESE_CLOSED
        after_index += 1
      elsif @tokens[start_index] =~ IDENTIFIER
        table, after_index = parse_name( start_index )
      else
        raise
      end
      after_index += 1 if @tokens[after_index] =~ AS
      if @tokens[after_index] =~ IDENTIFIER
        return [Table.new( table, @tokens[after_index] ), after_index + 1]
      else
        return [Table.new( table ), after_index]
      end
    end

    def parse_name( start_index )
      raise unless @tokens[start_index] =~ IDENTIFIER
      name = Variable.new( @tokens[start_index] )
      after_index = start_index + 1
      while @tokens[after_index] =~ Operators::DOT.to_regexp
        after_index += 1
        raise unless @tokens[after_index] =~ IDENTIFIER
        name = BinaryOperation.new( Operators::DOT, name, Variable.new( @tokens[after_index] ) )
        after_index += 1
      end
      [name, after_index]
    end

    def parse_where( start_index )
      return WhereClause.new( Constant.new( true ) ) unless @tokens[start_index] =~ WHERE
      after_index = start_index + 1
      expression, after_index = parse_expression( start_index ) do |t|
        !t
      end
      [WhereClause.new( expression ), after_index]
    end

    def parse_select_clause( start_index )
      raise unless @tokens[start_index] =~ SELECT
      after_index = start_index + 1
      after_index, column = parse_column( after_index )
      columns = [column]
      until @tokens[after_index] =~ FROM
        after_index, column = parse_column( after_index )
        columns.push( column )
      end
    end

    def parse_column( start_index )
      expression, after_index = if @tokens[start_index] =~ ALL_SYMBOL
        '*'
      else
        parse_expression( start_index) do |token|
          !token || token =~ IDENTIFIER || token =~ KOMMA
        end
      end
      after_index += 1 if @tokens[after_index] =~ AS
      if @tokens[after_index] =~ IDENTIFIER
        return [Column.new( expression, @tokens[after_index] ), after_index + 1]
      else
        return [Column.new( expression ), after_index]
      end
    end

    def parse_expression( start_index, &condition )
      after_index = start_index
      token = @tokens[after_index]
      @expression_stack = []
      @operator_stack = []
      bin_op = false
      parentheses_open = 0
      until parentheses_open == 0 && bin_op && condition.call( token )
        if !bin_op && @operator_stack.last =~ PARENTHESE_OPEN && token =~ SELECT
          select, after_index = parse_select( after_index )
          raise unless @operator_stack.pop =~ PARENTHESE_CLOSED
          @expression_stack.push( select )
        elsif !bin_op && token =~ CONSTANT
          @expression_stack.push( Constant.new( token.to_i ) ) # to_i is not general!
          bin_op = true
        elsif !bin_op && token =~ IDENTIFIER
          @expression_stack.push( Variable.new( token ) )
          if token[after_index + 1] =~ PARENTHESE_OPEN
            @expression_stack.push( :func )
          else
            bin_op = true
          end
        elsif !bin_op && token =~ UNARY_OPERATOR
          @expression_stack.push( Operators.choose_unary_operator( token ) )
        elsif bin_op && token =~ KOMMA
          until_parenthese
          raise unless @operator_stack.last == "("
          bin_op = false
        elsif bin_op && token =~ BINARY_OPERATOR
          operator = Operators.choose_binary_operator( token )
          last_op = @operator_stack.last
          while last_op.kind_of?(Operator) && (
              ( last_op >= operator && !operator.right_associative ) ||
              ( last_op > operator && operator.right_associative )
            )
            pop_operator
            last_op = @operator_stack.last
          end
          @operator_stack.push( operator )
          bin_op = false
        elsif !bin_op && token =~ PARENTHESE_OPEN
          @operator_stack.push(token)
          parentheses_open += 1
        elsif bin_op && token =~ PARENTHESE_CLOSED
          until_parenthese
          parentheses_open -= 1
          raise unless @operator_stack.pop == "("
          pop_function if @operator_stack.last =~ IDENTIFIER
          bin_op = true
        else
          raise "bin_op: #{bin_op}; token: #{token}"
        end
        after_index += 1
        token = @tokens[after_index]
        raise unless token
      end
      until @operator_stack.empty?
        pop_operator
      end
      raise unless parentheses_open == 0
      raise unless @expression_stack.length == 1
      return [@expression_stack[0], after_index]
    end

    def until_parenthese
      raise if @operator_stack.empty?
      until @operator_stack.last =~ PARENTHESE_OPEN
        pop_operator
        raise if @operator_stack.empty?
      end
    end

    def pop_operator
      operator = @operator_stack.last
      if operator.kind_of?( Operator ) && operator.is_binary?
        pop_binary_operator
      elsif operator.kind_of?( Operator ) && operator.is_unary?
        pop_unary_operator
      else
        raise
      end
    end

    def pop_function
      operator = @operator_stack.pop
      raise unless operator.kind_of?( Variable )
      raise if @expression_stack.empty?
      expression = @expression_stack.pop
      parameters = []
      until expression == :func
        raise unless expression.kind_of?( Expression )
        parameters.push( expression )
        raise if @expression_stack.empty?
        expression = @expression_stack.pop
      end
      @expression_stack.push( FunctionApplication.new( operator, parameters ) )
    end

    def pop_binary_operator
      raise if @operator_stack.empty?
      operator = @operator_stack.pop
      raise unless operator.kind_of?( Operator ) && operator.is_binary?
      raise if @expression_stack.length < 2
      raise unless @expression_stack.last.kind_of?(Expression)
      raise unless @expression_stack[-2].kind_of?(Expression)
      @expression_stack.push( FunctionApplication.new(
          Operators.choose_binary_operator( operator ), *@expression_stack.pop( 2 )
        ) )
    end

    def pop_unary_operator
      raise if @operator_stack.empty?
      operator = @operator_stack.pop
      raise unless operator.kind_of?( Operator ) && operator.is_binary?
      raise if @expression_stack.empty || !@expression_stack.last.kind_of?( Expression )
      @expression_stack.push( FunctionApplication.new(
          Operators.choose_unary_operator( operator ), @expression_stack.pop
        ) )
    end

  end
  
end
