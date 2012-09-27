require 'ast/rel_alg_operators/rel_alg_operator'

module SquirrelDB

  module AST

    class Selection < RelAlgOperator

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

    end

  end

end
