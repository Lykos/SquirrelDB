require 'forwardable'
require 'ast/iterators/rel_alg_iterator' 

module SquirrelDB

  module AST

    class Projector < RelAlgIterator

      def initialize( renamings, inner )
        @renamings = renamings
        @inner = inner
      end

      def_delegators :@inner, :itopen, :close, :size, :rewind

      def next_item
        super
        t = @inner.next_item
        return nil unless t
        @renamings.collect do |r|
          r.evaluate( TupleState.new( @state, t ) )
        end
      end
      
      def rewind
        super
        @inner.rewind
      end
      
      def cost
        @cost ||= @inner.cost * @renamings.cost
      end
      
      def accept(visitor)
        let_visit( visitor, @renamings.collect { |r| r.accept(visitor) }, @inner.accept(visitor) )
      end

    end

  end

end
