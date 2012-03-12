require 'forwardable'

module RubyDB

  module Data

    class Projector < Iterator

      def initialize( renamings, inner )
        @renamings = renamings
        @inner = inner
      end

      def_delegators :@inner, :open, :close, :size, :rewind

      def next_item
        t = @inner.next_element
        return nil unless t
        @renamings.collect do |r|
          r.evaluate( TupleState.new( @state, t ) )
        end
      end

    end

  end

end
