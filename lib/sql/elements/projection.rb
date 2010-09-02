require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class Projection < SyntacticUnit

      def initialize( renamings, expression )
        @renamings = renamings
        @expression = expression
      end

      attr_reader :renamings, :expressions

      def ==(other)
        super && @renamings == other.renamings && @expression == other.expression
      end
      
    end

  end
  
end
