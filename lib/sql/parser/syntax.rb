require 'eregex'

module Sql
  
  # Sets up a few constants that describe the syntax.
  #
  module Syntax
    # _K stands for keyword and is necessary because else it would be a Ruby keyword.

    TRUE_K = /true/
    FALSE_K = /false/
    LESS_OR_EQUAL_THAN = /<=/
    GREATER_OR_EQUAL_THAN = />=/
    LESS_THAN = /</
    GREATER_THAN = />/
    EQUAL_TO = /=/
    UNEQUAL_TO = Regexp.union(/!=/, /<>/)
    BINARY_RELATIONAL_OPERATOR = Regexp.union( LESS_OR_EQUAL_THAN,
      GREATER_OR_EQUAL_THAN, LESS_THAN, GREATER_THAN, EQUAL_TO,
      UNEQUAL_TO )
  
    OR_K = /or/
    AND_K = /and/
    BINARY_BOOLEAN_OPERATOR = Regexp.union( OR_K, AND_K )
  
    NOT_K = /not/
  
    PLUS = /\+/
    MINUS = /-/
    TIMES = /\*/
    DIVIDED_BY = /\//
    BINARY_ARITHMETIC_OPERATOR = Regexp.union( PLUS, MINUS, TIMES, DIVIDED_BY )
  
    PARENTHESE_OPEN = /\(/
    PARENTHESE_CLOSED = /\)/
    PARENTHESE = Regexp.union( PARENTHESE_OPEN, PARENTHESE_CLOSED )
    
    INTEGER = /\d+/
  
    IDENTIFIER = /\w+/

    KOMMA = /,/
  
    TOKEN = Regexp.union( TRUE_K, BINARY_COMPARATION_OPERATOR,
      BINARY_BOOLEAN_OPERATOR, BINARY_ARITHMETIC_OPERATOR, NOT_K, PARENTHESE,
      INTEGER, IDENTIFIER, KOMMA )

    ARITHMETIC_CONTINUE = Regexp.union( PARENTHESE_OPEN, IDENTIFIER, INTEGER )

  end

end
