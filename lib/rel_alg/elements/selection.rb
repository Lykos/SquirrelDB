require 'rel_alg/elements/rel_alg_operation'

module RubyDB

  module RelAlg

    class Selection < SyntacticUnit

      def initialize( expression, inner )
        @expression = expression
        @inner = inner
      end

      attr_reader :expression, :inner

      def to_s
        "Selection_{ " + @expression.to_s + " }( " + @inner.to_s + " )"
      end

      def inspect
        "Selection_{ " + @expression.to_s + " }( " + @inner.to_s + " )"
      end

      def ==(other)
        super && @expression == other.expression && @inner == other.inner
      end

      def visit( visitor )
        let_visit( visitor, @inner.visit( visitor ), @expression.visit( visitor ) )
      end

    end

  end

end
