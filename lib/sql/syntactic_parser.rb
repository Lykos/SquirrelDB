require 'sql/syntax'
require 'ast/common/all'
require 'ast/sql/all'
require 'schema/type'
require 'sql/lexical_parser'

# TODO Redo this with Racc
module SquirrelDB

  module SQL

    class SyntacticParser

      include Syntax

      def process( tokens )
        @tokens = tokens
        if @tokens[0] =~ SELECT
          parse_select( 0 )[0]
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
          raise ParseError, "Unknown statement type #{@tokens[0]}."
        end
      end

      private
      
      def parse_insert(start_index)
        raise InternalParserError, "Insert doesn't start with `insert'." unless @tokens[start_index] =~ INSERT
        raise ParseError, "Expected `into' after `insert'." unless @tokens[start_index + 1] =~ INTO
        index = start_index + 2
        table_name, index = parse_name( index )
        raise ParseError, "Expected `(' after #{@tokens[index - 1]}." unless @tokens[index] =~ PARENTHESE_OPEN
        index += 1
        columns = []
        loop do 
          name, index = parse_name(index)
          columns << name
          if @tokens[index] =~ PARENTHESE_CLOSED
            index += 1
            break
          else
            raise ParseError, "Expected `,' or `)' after #{@tokens[index - 1]}."  unless @tokens[index] =~ KOMMA
          end
          index += 1
        end        
        if @tokens[index] =~ VALUES
          values, index = parse_values(index)
        elsif @tokens[index] =~ SELECT
          values, index = parse_select(index)
        else
          raise ParseError, "Expected `select' or `values' after `insert'."
        end
        Insert.new(table_name, columns, values)
      end
      
      def parse_values(start_index)
        raise ParseError, "Expected `values' or select statement after #{@tokens[start_index - 1]}." unless @tokens[start_index] =~ VALUES
        raise ParseError, "Expected `(' after `values'." unless @tokens[start_index + 1] =~ PARENTHESE_OPEN
        index = start_index + 2
        values = []
        loop do
          expression, index = parse_expression(index) { |t| t =~ KOMMA || t =~ PARENTHESE_CLOSED }
          values << expression
          if @tokens[index] =~ PARENTHESE_CLOSED
            index += 1
            break
          else
            raise ParseError, "Expected `,' or `)' after #{@tokens[index - 1]}."  unless @tokens[index] =~ KOMMA
          end
          index += 1
        end
        [values, index]
      end
      
      def parse_create(start_index)
        if @tokens[start_index + 1] =~ TABLE
          parse_create_table(start_index)
        else
          raise ParseError, "Only table is supported to create."  
        end
      end
      
      def parse_create_table(start_index)
        raise InternalParserError, "Create table doesn't start with `create'." unless @tokens[start_index] =~ CREATE
        raise ParseError, "Only `table' is supported after `create'." unless @tokens[start_index + 1] =~ TABLE
        index = start_index + 2
        table_name, index = parse_name(index)
        raise ParseError, "Expected `(' after `create table'." unless @tokens[index] =~ PARENTHESE_OPEN
        index += 1
        columns = []
        i = 0
        until @tokens[index] =~ PARENTHESE_CLOSED
          raise ParseError, "Expected identifier as column name.." unless @tokens[index] =~ IDENTIFIER
          name = Variable.new(@tokens[index])
          type, index = parse_type(index + 1)
          if @tokens[index] =~ CONSTANT
            default, index = parse_default(index)
          else
            default = Constant.null(type)
          end
          columns << Column.new(name, type, i, default)
          break if @tokens[index] =~ PARENTHESE_CLOSED
          raise ParseError, "Expected `,' after #{@tokens[index - 1]}" unless @tokens[index] =~ KOMMA
          index += 1
          i += 1
        end
        CreateTable.new(table_name, columns)
      end
      
      def parse_default(start_index)
        raise InternalParserError, "Expected `default' in default clause." unless @tokens[start_index] =~ DEFAULT
        [parse_constant(@tokens[start_index + 1]), start_index + 2]
      end
      
      def parse_type(start_index)
        raise ParseError, "Unknown type #{start_index[type]}." unless @tokens[start_index] =~ TYPE
        if @tokens[start_index] =~ INTEGER_T
          [Schema::Type::INTEGER, start_index + 1]
        elsif @tokens[start_index] =~ BOOLEAN_T
          [Schema::Type::BOOLEAN, start_index + 1]
        elsif @tokens[start_index] =~ STRING_T
          [Schema::Type::STRING, start_index + 1]
        elsif @tokens[start_index] =~ DOUBLE_T
          [Schema::Type::DOUBLE, start_index + 1]
        elsif @tokens[start_index] =~ SHORT_T
          [Schema::Type::SHORT, start_index + 1]
        else
          raise InternalParserError, "Unknown type #{start_index[type]}."
        end
      end

      def parse_select(start_index)
        select_clause, after_index = parse_select_clause(start_index)
        from_clause, after_index = parse_from(after_index)
        where_clause, after_index = parse_where(after_index)
        [SelectStatement.new(select_clause, from_clause, where_clause), after_index]
      end

      def parse_from(start_index)
        return [FromClause.new([]), start_index] unless @tokens[start_index] =~ FROM
        after_index = start_index + 1
        table, after_index = parse_table(after_index)
        tables = [table]
        until @tokens[after_index] =~ WHERE || !@tokens[after_index] || @tokens[after_index] =~ PARENTHESE_CLOSED
          raise ParseError, "Comma expected instead of #{@tokens[after_index]}." unless @tokens[after_index] =~ KOMMA
          after_index += 1
          table, after_index = parse_table(after_index)
          tables.push(table)
        end
        [FromClause.new(tables), after_index]
      end

      def parse_table(start_index)
        if @tokens[start_index] =~ PARENTHESE_OPEN
          table, after_index = parse_select(start_index + 1)
          raise ParseError, "missing right parenthesis" unless @tokens[after_index] =~ PARENTHESE_CLOSED
          after_index += 1
        elsif @tokens[start_index] =~ IDENTIFIER
          table, after_index = parse_name(start_index)
        else
          raise ParseError, "Table #{@tokens[start_index]} is neither an identifier nor a select statement."
        end
        after_index += 1 if @tokens[after_index] =~ AS
        if @tokens[after_index] =~ IDENTIFIER && !(@tokens[after_index] =~ WHERE)
          return [Renaming.new(table, Variable.new(@tokens[after_index])), after_index + 1]
        else
          return [table, after_index]
        end
      end

      def parse_name(start_index)
        raise ParseError, "Expected object name after #{@tokens[start_index - 1]}." unless @tokens[start_index] =~ IDENTIFIER
        name = Variable.new( @tokens[start_index] )
        after_index = start_index + 1
        while @tokens[after_index] =~ DOT
          after_index += 1
          raise ParseError, "Expected identifier instead of #{@tokens[after_index]} in an object name." unless @tokens[after_index] =~ IDENTIFIER
          name = ScopedVariable.new( name, Variable.new( @tokens[after_index] ) )
          after_index += 1
        end
        [name, after_index]
      end

      def parse_where( start_index )
        return [WhereClause.new( Constant::TRUE ), start_index] unless @tokens[start_index] =~ WHERE
        after_index = start_index + 1
        expression, after_index = parse_expression( after_index ) { |t| !t }
        [WhereClause.new( expression ), after_index]
      end

      def parse_select_clause( start_index )
        raise InternalParserError, "Select clause has to start with `select'." unless @tokens[start_index] =~ SELECT
        after_index = start_index + 1
        column, after_index = parse_column( after_index )
        columns = [column]
        until @tokens[after_index] =~ FROM || !@tokens[after_index]
          raise ParseError, "Expected `,' after #{@tokens[after_index - 1]}" unless @tokens[after_index] =~ KOMMA
          after_index += 1
          column, after_index = parse_column( after_index )
          columns.push( column )
        end
        [SelectClause.new( columns ), after_index]
      end

      def parse_column( start_index )
        expression, after_index = if @tokens[start_index] =~ ALL_SYMBOL
          [WildCard.new, start_index + 1]
        else
          parse_expression(start_index) do |token|
            !token || token =~ AS || token =~ KOMMA || token =~ FROM
          end
        end
        if @tokens[after_index] =~ AS
          return [Renaming.new( expression, @tokens[after_index + 1] ), after_index + 2]
        else
          return [expression, after_index]
        end
      end

      def parse_expression(start_index, &condition)
        after_index = start_index
        token = @tokens[after_index]
        @expression_stack = []
        @operator_stack = []
        is_infix = false
        parentheses_open = 0
        until parentheses_open == 0 && is_infix && condition.call(token)
          raise ParseError, "Tokens empty and not finished." unless token
          if !is_infix && @operator_stack.last == "(" && token =~ SELECT
            select, after_index = parse_select( after_index )
            raise ParseError, "Query inside expression has to be ended with `)'." unless @tokens[after_index] =~ PARENTHESE_CLOSED
            after_index += 1
            raise InternalParseError, "Unexpected operator stack top." unless @operator_stack.pop == "("
            @expression_stack.push( select )
          elsif !is_infix && token =~ CONSTANT
            @expression_stack.push( parse_constant( token ) )
            is_infix = true
            after_index += 1
          elsif !is_infix && token =~ IDENTIFIER
            variable, after_index = parse_name(after_index)
            if @tokens[after_index + 1] =~ PARENTHESE_OPEN
              @operator_stack.push(variable)
              @expression_stack.push(:func)
            else
              @expression_stack.push(variable)
              is_infix = true
            end
          elsif token =~ ALL_SYMBOL
            @expression_stack.push('*') 
            after_index += 1
          elsif !is_infix && token =~ UNARY_OPERATOR
            @operator_stack.push( Operator.choose_unary_operator( token ) )
            after_index += 1
          elsif is_infix && token =~ KOMMA
            until_parenthese
            raise InternalParserError, "Invalid operator stack top." unless @operator_stack.pop == "("
            is_infix = false
            after_index += 1
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
            after_index += 1
          elsif !is_infix && token =~ PARENTHESE_OPEN
            @operator_stack.push(token)
            parentheses_open += 1
            after_index += 1
          elsif is_infix && token =~ PARENTHESE_CLOSED
            until_parenthese
            parentheses_open -= 1
            raise ParseError, "Closed too many parentheses." unless @operator_stack.pop == "("
            pop_function if @operator_stack.last =~ IDENTIFIER
            is_infix = true
            after_index += 1
          else
            raise ParseError, "Could not find a mapping for token #{token} (is_infix: #{is_infix})"
          end
          token = @tokens[after_index]
        end
        until @operator_stack.empty?
          pop_operator
        end
        raise ParseError, "Not all parentheses closed." unless parentheses_open == 0
        raise InternalParserError, "Expression stack has more than one entry."  unless @expression_stack.length == 1
        return [@expression_stack[0], after_index]
      end

      def until_parenthese
        raise InternalParserError, "Comma list has no `(' at the beginning." if @operator_stack.empty?
        until @operator_stack.last =~ PARENTHESE_OPEN
          pop_operator
          raise ParseError, "Missing parenthesis" if @operator_stack.empty?
        end
      end

      def pop_operator
        operator = @operator_stack.last
        if operator.kind_of?( Operator ) && operator.is_binary?
          pop_binary_operator
        elsif operator.kind_of?( Operator ) && operator.is_unary?
          pop_unary_operator
        elsif operator.variable?
          pop_function
        else
          raise InternalParserError, "Invalid element on operator stack: #{operator}."
        end
      end

      def pop_function
        operator = @operator_stack.pop
        raise InternalParserError, "Expected variable instead of #{operator} on operator stack." unless operator.variable?
        raise InternalParserError, "Expression stack unexpectedly empty." if @expression_stack.empty?
        expression = @expression_stack.pop
        parameters = []
        until expression == :func
          raise InternalParserError, "Unexpected element on expression stack: #{exression}." unless expression.kind_of?( Element )
          parameters.push(expression)
          raise InternalParserError, "Expression stack unexpectedly empty." if @expression_stack.empty?
          expression = @expression_stack.pop
        end
        @expression_stack.push( FunctionApplication.new( operator, parameters.reverse ) )
      end

      def pop_binary_operator
        raise InternalParserError, "Expression stack unexpectedly empty." if @expression_stack.empty?
        operator = @operator_stack.pop
        raise InternalParseError, "Expected binary operator on operator stack instead of #{operator}." unless operator.kind_of?( Operator ) && operator.is_binary?
        raise InternalParseError, "Expression stack doesn't contain two elements." if @expression_stack.length < 2
        raise InternalParseError, "Got #{@expression_stack.last.inspect} as second part of a binary operation." unless @expression_stack.last.kind_of?( Element )
        raise InternalParseError, "Got #{@expression_stack[-2].inspect} as second part of a binary operation." unless @expression_stack[-2].kind_of?( Element )
        @expression_stack.push( BinaryOperation.new(
            operator, *@expression_stack.pop( 2 )
          ) )
      end

      def pop_unary_operator
        raise InternalParserError, "Expression stack unexpectedly empty." if @expression_stack.empty?
        operator = @operator_stack.pop
        raise InternalParseError, "Expected unary operator on operator stack instead of #{operator}." unless operator.kind_of?(Operator) && operator.is_unary?
        raise InternalParseError, "Got #{@expression_stack.last.inspect} as operand of a unary operation." if @expression_stack.empty? || !@expression_stack.last.kind_of?( Element )
        @expression_stack.push( UnaryOperation.new(
            operator, @expression_stack.pop
          ) )
      end

      def parse_constant(token)
        if token =~ BOOLEAN
          if token =~ TRUE_K
            Constant.new(true, Schema::Type::BOOLEAN)
          elsif token =~ FALSE_K
            Constant.new(false, Schema::Type::BOOLEAN)
          elsif token =~ UNKNOWN
            Constant.new(nil, Schema::Type::BOOLEAN)
          else
            raise ParserCasesError, "Unknown boolean #{token}."
          end
        elsif token =~ INTEGER
          Constant.new(token.to_i, Schema::Type::INTEGER)
        elsif token =~ DOUBLE
          Constant.new(token.to_i, Schema::Type::DOUBLE)
        elsif token =~ STRING
          # TODO String escaping etc
          Constant.new(token[1..-2], Schema::Type::STRING)
        end
      end

    end

  end

end
