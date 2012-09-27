require 'ast/rel_alg_operators/rel_alg_operator'

module SquirrelDB

  module AST

    class Projection < RelAlgOperator

      def initialize( renamings, inner )
        @renamings = renamings
        @inner = inner
      end

      attr_reader :renamings, :inner
      
      def ==(other)
        super && @renamings == other.renamings && @inner == other.inner
      end
      
    end

  end
  
end
