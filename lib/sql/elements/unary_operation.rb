require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class UnaryOperation < SyntacticUnit

      def initialize( operator, inner )
        @operator = operator
        @inner = inner
      end

      attr_reader :operator, :inner

    end

  end

end
