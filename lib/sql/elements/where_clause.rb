require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class WhereClause < SyntacticUnit

      def initialize(expression)
        @expression = expression
      end
    
      attr_reader :expression

      def to_s
        "where " + @expression.to_s
      end

      def inspect
        "WhereClause( " + @expression.inspect + " )"
      end

      def ==(other)
        super && @expression == other.expression
      end

    end

  end
  
end
