require 'ast/rel_alg_operators/rel_alg_operator'

module SquirrelDB

  module AST

    class Projection < RelAlgOperator

      def initialize( renamings, inner )
        @renamings = renamings
        @inner = inner
      end

      attr_reader :renamings, :inner
      
      def accept(visitor)
        let_visit( visitor, @renamings.map { |r| r.accept( visitor ) }, @inner.accept( visitor ) )
      end

      def ==(other)
        super && @renamings == other.renamings && @inner == other.inner
      end
      
    end

  end
  
end
