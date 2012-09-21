require 'ast/element'

module SquirrelDB

  module AST

    class Projection < AST::Element

      def initialize( renamings, inner )
        @renamings = renamings
        @inner = inner
      end

      attr_reader :renamings, :inner
      
      def accept(visitor)
        let_visit( visitor, @renamings.accept( visitor ), @inner.accept( visitor ) )
      end

      def ==(other)
        super && @renamings == other.renamings && @inner == other.inner
      end
      
    end

  end
  
end
