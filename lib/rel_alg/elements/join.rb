require 'rel_alg/elements/rel_alg_operation'

module RubyDB

  module RelAlg

    class Join < RelAlgOperation

      def initialize( expression, left, right )
        @expression = expression
        @left = left
        @right = right
      end

      attr_reader :expression, :left, :right

      def visit( visitor )
        let_visit( visitor, @left.visit( visitor ), @right.visit( visitor ), @expression.visit( visitor ) )
      end
      
    end

  end

end
