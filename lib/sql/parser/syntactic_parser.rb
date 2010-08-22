require 'syntax'
require 'operators'
require 'operator'
require 'binary_operation'
require 'expression'
require 'constant'
require 'function'
require 'unary_operation'
require 'eregex'

module Sql

  class SyntacticParser

    include Syntax

    def parse( tokens )
      select_clause, after_value = parse_select( tokens, 0 )
      from_clause, after_value = parse_from( tokens, after_value )
      where_clause, after_value = parse_where( tokens, after_value )
      SelectStatement.new(select_clause, from_clause, where_clause)
    end

    def parse_from( tokens, start_value )
      return unless tokens[start_value] =~ FROM
      after_value = start_value + 1
      
    end

    def parse_from( tokens, start_value )
      return unless tokens[start_value] =~ WHERE
      after_value = start_value + 1
      expression, after_value = parse_expression( tokens, start_value )
      [WhereClause.new( expression ), after_value]
    end

    def parse_select( tokens, start_value )
      raise unless tokens[start_value] =~ SELECT
      after_value = start_value + 1
      columns = []
      after_value, column = parse_column( tokens, after_value )
      columns.push( column )
      until tokens[after_value] =~ FROM
        after_value, column = parse_column( tokens, after_value )
        columns.push( column )
      end
    end

    def parse_column( tokens, start_value )
      expression, after_value = parse_expression( tokens, start_value) do |token|
        token == nil || token =~ IDENTIFIER || token =~ KOMMA
      end
      after_value += 1 if tokens[after_value] =~ AS
      if tokens[after_value] =~ IDENTIFIER
        return [Column.new( expression, tokens[after_value] ), after_value + 1]
      else
        return [Column.new( expression ), after_value]
      end
    end

    def parse_expression( tokens, start_value, &condition )
      after_value = start_value
      token = tokens[after_value]
      @expression_stack = []
      @operator_stack = []
      bin_op = false
      parentheses_open = 0
      until parentheses_open == 0 && bin_op && condition.call( token )
        if !bin_op && token =~ CONSTANT
          @expression_stack.push( Constant.new( token.to_i ) ) # to_i is not general!
          bin_op = true
        elsif !bin_op && token =~ IDENTIFIER
          if token[after_value + 1] =~ PARENTHESE_OPEN
            @expression_stack.push( Variable.new( token ) )
            bin_op = true
          else
            @operator_stack.push( token )
            @expression_stack.push( :func )
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
        after_value += 1
        token = tokens[after_value]
        raise unless token
      end
      until @operator_stack.empty?
        pop_operator
      end
      raise unless parentheses_open == 0
      raise unless @expression_stack.length == 1
      return [@expression_stack[0], after_value]
    end

    def until_parenthese
      raise if @operator_stack.empty?
      operator = @operator_stack.last
      raise if operator =~ PARENTHESE_OPEN
      until operator =~ PARENTHESE_OPEN
        pop_operator
        raise if @operator_stack.empty?
        operator = @operator_stack.last
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
      raise unless operator =~ IDENTIFIER
      raise if @expression_stack.empty?
      expression = @expression_stack.pop
      parameters = []
      until expression == :func
        raise unless expression.kind_of?( Expression )
        parameters.push( expression )
        raise if @expression_stack.empty?
        expression = @expression_stack.pop
      end
      @expression_stack.push( Function.new( operator, parameters ) )
    end

    def pop_binary_operator
      raise if @operator_stack.empty?
      operator = @operator_stack.pop
      raise unless operator.kind_of?( Operator ) && operator.is_binary?
      raise if @expression_stack.length < 2
      raise unless @expression_stack.last.kind_of?(Expression)
      raise unless @expression_stack[-2].kind_of?(Expression)
      @expression_stack.push( BinaryOperation.new(
          Operators.choose_binary_operator( operator ), *@expression_stack.pop( 2 )
        ) )
    end

    def pop_unary_operator
      raise if @operator_stack.empty?
      operator = @operator_stack.pop
      raise unless operator.kind_of?( Operator ) && operator.is_binary?
      raise if @expression_stack.empty || !@expression_stack.last.kind_of?( Expression )
      @expression_stack.push( UnaryOperation.new(
          Operators.choose_unary_operator( operator ), @expression_stack.pop
        ) )
    end

  end
  
end
