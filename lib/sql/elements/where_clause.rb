require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class WhereClause < SyntacticUnit

      def initialize(expression)
        @expression = expression
      end
    
      attr_reader :expression

    end

  end
  
end
