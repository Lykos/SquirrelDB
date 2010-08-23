require 'eregex'
require 'operators'

module Sql
  
  # Sets up a few constants that describe the syntax.
  #
  module Syntax
    # _K stands for keyword and is necessary because else it would be a Ruby keyword.

    TRUE_K = /true/
    FALSE_K = /false/
    BINARY_OPERATOR = Regexp.union(
      Operators::ALL_OPERATORS.select { |op| op.is_binary? }.collect { |op| op.to_regexp }
    )
    UNARY_OPERATOR = Regexp.union(
      Operators::ALL_OPERATORS.select { |op| op.is_unary? }.collect { |op| op.to_regexp }
    )
    PARENTHESE_OPEN = /\(/
    PARENTHESE_CLOSED = /\)/
    PARENTHESE = Regexp.union( PARENTHESE_OPEN, PARENTHESE_CLOSED )
    
    INTEGER = /\d+/

    CONSTANT = INTEGER
  
    IDENTIFIER = /\w+/

    SELECT = /[Ss][Ee][Ll][Ee][Cc][Tt]/
    AS = /[Aa][Ss]/
    FROM = /[Ff][Rr][Oo][Mm]/
    WHERE = /[Ww][Hh][Ee][Rr][Ee]/
    INSERT = /[Ii][Nn][Ss][Ee][Rr][Tt]/
    UPDATE = /[Uu][Pp][Dd][Aa][Tt][Ee]/
    DELETE = /[Dd][Ee][Ll][Ee][Tt][Ee]/
    CREATE = /[Cc][Rr][Ee][Aa][Tt][Ee]/
    DROP = /[Dd][Rr][Oo][Pp]/
    ALTER = /[Aa][Ll][Tt][Ee][Rr]/
    GRANT = /[Gg][Rr][Aa][Nn][Tt]/
    TRUNCATE = /[Tt][Rr][Uu][Nn][Cc][Aa][Tt][Ee]/

    ALL_SYMBOL = /\*/
    KOMMA = /,/
  
    TOKEN = Regexp.union( TRUE_K, BINARY_OPERATOR, UNARY_OPERATOR, PARENTHESE,
      CONSTANT, IDENTIFIER, KOMMA, ALL_SYMBOL )

    EXPRESSION_CONTINUE = Regexp.union( PARENTHESE_OPEN, IDENTIFIER, CONSTANT )

  end

end
