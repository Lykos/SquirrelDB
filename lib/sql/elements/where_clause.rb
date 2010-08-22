require 'syntactic_unit'

module Sql

  class WhereClause < SyntacticUnit

    def initialize(expression)
      @expression = expression
    end
    
    attr_reader :expression

  end
  
end
