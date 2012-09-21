require 'sql/elements/syntactic_unit'

module RubyDB

  module RelAlg

    class Projection < Sql::SyntacticUnit

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
