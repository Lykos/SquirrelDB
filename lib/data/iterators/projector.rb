require 'forwardable'
require 'data/iterators/rel_alg_iterator' 

module RubyDB

  module Data

    class Projector < RelAlgIterator

      def initialize( renamings, inner )
        @renamings = renamings
        @inner = inner
      end

      def_delegators :@inner, :open, :close, :size, :rewind

      def next_item
        super
        t = @inner.next_element
        return nil unless t
        @renamings.collect do |r|
          r.evaluate( TupleState.new( @state, t ) )
        end
      end
      
      def rewind
        @inner.rewind
      end
      
      def cost
        @cost ||= @inner.cost * @renamings.cost
      end

    end

  end

end
