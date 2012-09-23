require 'ast/common/operator'

module SquirrelDB

  module SQL
      
    # Sets up a few constants that describe the syntax.
    #
    module Syntax
      
      include AST

      # _K stands for keyword and is necessary because else it would be a Ruby keyword.

      BINARY_OPERATOR = Regexp.union(
        Operator::ALL_OPERATORS.select { |op| op.is_binary? }.collect { |op| op.to_regexp }
      )
      UNARY_OPERATOR = Regexp.union(
        Operator::ALL_OPERATORS.select { |op| op.is_unary? }.collect { |op| op.to_regexp }
      )
      PARENTHESE_OPEN = /\(/
      PARENTHESE_CLOSED = /\)/
      PARENTHESE = Regexp.union( PARENTHESE_OPEN, PARENTHESE_CLOSED )
    
      INTEGER = /\d+/
      DOUBLE = /\d+\.\d+/
      STRING = /\'.*?\'/

      TRUE_K = /[Tt][Rr][Uu][Ee]/
      FALSE_K = /[Ff][Aa][Ll][Ss][Ee]/
      UNKNOWN_K = /[Uu][Nn][Kk][Nn][Oo][Ww][Nn]/

      BOOLEAN = Regexp.union( TRUE_K, FALSE_K, UNKNOWN_K )

      CONSTANT = Regexp.union( INTEGER, DOUBLE, STRING, BOOLEAN )

      IDENTIFIER = /\w+/

      SELECT = /[Ss][Ee][Ll][Ee][Cc][Tt]/
      AS = /[Aa][Ss]/
      FROM = /[Ff][Rr][Oo][Mm]/
      WHERE = /[Ww][Hh][Ee][Rr][Ee]/
      INSERT = /[Ii][Nn][Ss][Ee][Rr][Tt]/
      UPDATE = /[Uu][Pp][Dd][Aa][Tt][Ee]/
      DELETE = /[Dd][Ee][Ll][Ee][Tt][Ee]/
      CREATE = /[Cc][Rr][Ee][Aa][Tt][Ee]/
      TABLE = /[Tt][Aa][Bb][Ll][Ee]/
      DROP = /[Dd][Rr][Oo][Pp]/
      ALTER = /[Aa][Ll][Tt][Ee][Rr]/
      GRANT = /[Gg][Rr][Aa][Nn][Tt]/
      TRUNCATE = /[Tt][Rr][Uu][Nn][Cc][Aa][Tt][Ee]/
      
      INTEGER_T = /[Ii][Nn][Tt][Ee][Gg][Ee][Rr]/
      BOOLEAN_T = /[Bb][Oo][Oo][Ll][Ee][Aa][Nn]/
      STRING_T = /[Ss][Tt][Rr][Ii][Nn][Gg]/
      DOUBLE_T = /[Dd][Oo][Uu][Bb][Ll][Ee]]/
      SHORT_T = /[Ss][Hh][Oo][Rr][Tt]/
      
      TYPE = Regexp.union( INTEGER_T, BOOLEAN_T, STRING_T, DOUBLE_T, SHORT_T )

      ALL_SYMBOL = /\*/
      KOMMA = /,/

      TOKEN = Regexp.union( BINARY_OPERATOR, UNARY_OPERATOR, PARENTHESE,
        CONSTANT, IDENTIFIER, KOMMA, ALL_SYMBOL )

      EXPRESSION_CONTINUE = Regexp.union( PARENTHESE_OPEN, IDENTIFIER, CONSTANT )

    end

  end

end
