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

      def ==(other)
        super && @operator == other.operator && @inner == other.inner
      end

      def visit( visitor )
        let_visit( visitor, @operator, @inner.visit( visitor ) )
      end

    end

  end

end
