require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class UnaryOperation < SyntacticUnit

      def initialize( operator, inner )
        @operator = operator
        @inner = inner
      end

      attr_reader :operator, :inner

      def to_s
        "(" + @operator.to_s + @inner.to_s + ")"
      end

      def inspect
        "(" + @operator.to_s + @inner.inspect + ")"
      end

    end

  end

end
