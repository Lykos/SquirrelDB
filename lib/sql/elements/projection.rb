require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class Projection < SyntacticUnit

      def initialize( renamings, expression )
        @renamings = renamings
        @expression = expression
      end

      attr_reader :renamings, :expressions
      
    end

  end
  
end
