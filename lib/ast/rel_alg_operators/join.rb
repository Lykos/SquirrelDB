require 'ast/rel_alg_operators/rel_alg_operator'

module SquirrelDB

  module AST

    class Join < RelAlgOperator

      def initialize( expression, left, right )
        @expression = expression
        @left = left
        @right = right
      end

      attr_reader :expression, :left, :right

    end

  end

end
