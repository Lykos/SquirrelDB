require 'ast/rel_alg_operation'

module SquirrelDB

  module AST

    class Join < ASTOperation

      def initialize( expression, left, right )
        @expression = expression
        @left = left
        @right = right
      end

      attr_reader :expression, :left, :right

      def accept( visitor )
        let_visit( visitor, @left.accept( visitor ), @right.accept( visitor ), @expression.accept( visitor ) )
      end
      
    end

  end

end
