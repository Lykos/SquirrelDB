require 'sql/parser/syntax'
require 'sql/elements/binary_operation'
require 'sql/elements/unary_operation'
require 'sql/elements/operator'
require 'sql/elements/constant'
require 'sql/elements/function_application'
require 'schema/type'
require 'sql/elements/renaming'
require 'sql/elements/select_clause'
require 'sql/elements/from_clause'
require 'sql/elements/where_clause'
require 'sql/elements/select_statement'
require 'sql/parser/lexical_parser'

module RubyDB

  module Sql

    class SyntacticParser

      def initialize( lexical_parser=LexicalParser.new )
        @lexical_parser = lexical_parser
      end

      include Syntax

      def process( string )
        @tokens = @lexical_parser.process( string )
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

      private

      def parse_select( start_index )
        select_clause, after_index = parse_select_clause( start_index )
        from_clause, after_index = parse_from( after_index )
        where_clause, after_index = parse_where( after_index )
        SelectStatement.new(select_clause, from_clause, where_clause)
      end

      def parse_from( start_index )
        return [FromClause.new( [] ), start_index] unless @tokens[start_index] =~ FROM
        after_index = start_index + 1
        table, after_index = parse_table( after_index )
        tables = [table]
        until @tokens[after_index] =~ WHERE || !@tokens[after_index]
          raise "Komma expected instead of #{@tokens[after_index]}" unless @tokens[after_index] =~ KOMMA
          after_index += 1
          table, after_index = parse_table( after_index )
          tables.push( table )
        end
        [FromClause.new( tables ), after_index]
      end

      def parse_table( start_index )
        if @tokens[start_index] =~ PARENTHESE_OPEN
          table, after_index = parse_select( start_index + 1 )
          raise "missing right parenthese" unless @tokens[after_index] =~ PARENTHESE_CLOSED
          after_index += 1
        elsif @tokens[start_index] =~ IDENTIFIER
          table, after_index = parse_name( start_index )
        else
          raise "Table #{@tokens[start_index]} is neither an identifier nor a select statement."
        end
        after_index += 1 if @tokens[after_index] =~ AS
        if @tokens[after_index] =~ IDENTIFIER && !(@tokens[after_index] =~ WHERE)
          return [Renaming.new( table, @tokens[after_index] ), after_index + 1]
        else
          return [Renaming.new( table, table.to_s ), after_index]
        end
      end

      def parse_name( start_index )
        raise unless @tokens[start_index] =~ IDENTIFIER
        name = Variable.new( @tokens[start_index] )
        after_index = start_index + 1
        while @tokens[after_index] =~ Operator::DOT.to_regexp
          after_index += 1
          raise unless @tokens[after_index] =~ IDENTIFIER
          name = BinaryOperation.new( Operator::DOT, name, Variable.new( @tokens[after_index] ) )
          after_index += 1
        end
        [name, after_index]
      end

      def parse_where( start_index )
        return [WhereClause.new( Constant.new( true, Schema::Type::BOOLEAN ) ), start_index] unless @tokens[start_index] =~ WHERE
        after_index = start_index + 1
        expression, after_index = parse_expression( after_index ) { |t| !t }
        [WhereClause.new( expression ), after_index]
      end

      def parse_select_clause( start_index )
        raise unless @tokens[start_index] =~ SELECT
        after_index = start_index + 1
        column, after_index = parse_column( after_index )
        columns = [column]
        until @tokens[after_index] =~ FROM || !@tokens[after_index]
          raise unless @tokens[after_index] =~ KOMMA
          after_index += 1
          column, after_index = parse_column( after_index )
          columns.push( column )
        end
        [SelectClause.new( columns ), after_index]
      end

      def parse_column( start_index )
        expression, after_index = if @tokens[start_index] =~ ALL_SYMBOL
          ['*', start_index + 1]
        else
          parse_expression( start_index ) do |token|
            !token || token =~ AS || token =~ KOMMA || token =~ FROM
          end
        end
        if @tokens[after_index] =~ AS
          return [Renaming.new( expression, @tokens[after_index + 1] ), after_index + 2]
        else
          return [Renaming.new( expression, expression.to_s ), after_index]
        end
      end

      def parse_expression( start_index, &condition )
        after_index = start_index
        token = @tokens[after_index]
        @expression_stack = []
        @operator_stack = []
        is_infix = false
        parentheses_open = 0
        until parentheses_open == 0 && is_infix && condition.call( token )
          raise "Tokens empty and not finished." unless token
          if !is_infix && @operator_stack.last =~ PARENTHESE_OPEN && token =~ SELECT
            select, after_index = parse_select( after_index )
            raise unless @operator_stack.pop =~ PARENTHESE_CLOSED
            @expression_stack.push( select )
          elsif !is_infix && token =~ CONSTANT
            @expression_stack.push( parse_constant( token ) )
            is_infix = true
          elsif !is_infix && token =~ IDENTIFIER
            if @tokens[after_index + 1] =~ PARENTHESE_OPEN
              @operator_stack.push( Variable.new( token ) )
              @expression_stack.push( :func )
            else
              @expression_stack.push( Variable.new( token ) )
              is_infix = true
            end
          elsif !is_infix && token =~ UNARY_OPERATOR
            @operator_stack.push( Operator.choose_unary_operator( token ) )
          elsif is_infix && token =~ KOMMA
            until_parenthese
            raise unless @operator_stack.last == "("
            is_infix = false
          elsif is_infix && token =~ BINARY_OPERATOR
            operator = Operator.choose_binary_operator( token )
            last_op = @operator_stack.last
            while last_op.kind_of?(Operator) && (
                ( last_op.precedence >= operator.precedence && !operator.right_associative? ) ||
                ( last_op.precedence > operator.precedence && operator.right_associative? )
              )
              pop_operator
              last_op = @operator_stack.last
            end
            @operator_stack.push( operator )
            is_infix = false
          elsif !is_infix && token =~ PARENTHESE_OPEN
            @operator_stack.push(token)
            parentheses_open += 1
          elsif is_infix && token =~ PARENTHESE_CLOSED
            until_parenthese
            parentheses_open -= 1
            raise unless @operator_stack.pop == "("
            pop_function if @operator_stack.last =~ IDENTIFIER
            is_infix = true
          else
            raise "Could not find a mapping for token #{token} (is_infix: #{is_infix})"
          end
          after_index += 1
          token = @tokens[after_index]
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
          raise "Missing parenthese" if @operator_stack.empty?
        end
      end

      def pop_operator
        operator = @operator_stack.last
        if operator.kind_of?( Operator ) && operator.is_binary?
          pop_binary_operator
        elsif operator.kind_of?( Operator ) && operator.is_unary?
          pop_unary_operator
        elsif operator.kind_of?( Variable )
          pop_function
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
          raise unless expression.kind_of?( SyntacticUnit )
          parameters.push( expression )
          raise if @expression_stack.empty?
          expression = @expression_stack.pop
        end
        @expression_stack.push( FunctionApplication.new( operator, parameters.reverse ) )
      end

      def pop_binary_operator
        raise if @operator_stack.empty?
        operator = @operator_stack.pop
        raise unless operator.kind_of?( Operator ) && operator.is_binary?
        raise if @expression_stack.length < 2
        raise "Got #{@expression_stack.last.inspect} as second part of a binary operation." unless @expression_stack.last.kind_of?( SyntacticUnit )
        raise "Got #{@expression_stack[-2].inspect} as second part of a binary operation." unless @expression_stack[-2].kind_of?( SyntacticUnit )
        @expression_stack.push( BinaryOperation.new(
            operator, *@expression_stack.pop( 2 )
          ) )
      end

      def pop_unary_operator
        raise if @operator_stack.empty?
        operator = @operator_stack.pop
        raise unless operator.kind_of?( Operator ) && operator.is_unary?
        raise if @expression_stack.empty? || !@expression_stack.last.kind_of?( SyntacticUnit )
        @expression_stack.push( UnaryOperation.new(
            operator, @expression_stack.pop
          ) )
      end

      def parse_constant( token )
        if token =~ BOOLEAN
          if token =~ TRUE_K
            Constant.new( true, Schema::Type::BOOLEAN )
          elsif token =~ FALSE_K
            Constant.new( false, Schema::Type::BOOLEAN )
          elsif token =~ UNKNOWN
            Constant.new( nil, Schema::Type::BOOLEAN )
          else
            raise
          end
        elsif token =~ INTEGER
          Constant.new( token.to_i, Schema::Type::INTEGER )
        elsif token =~ DOUBLE
          Constant.new( token.to_i, Schema::Type::DOUBLE )
        elsif token =~ STRING
          # TODO String escaping etc
          Constant.new( token[1..-2], Schema::Type::STRING)
        end
      end

    end

  end

end
