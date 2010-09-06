require 'forwardable'

module RubyDB

  module Data

    class Projector < Iterator

      def initialize( renamings, inner, evaluator )
        @renamings = renamings
        @inner = inner
        @evaluator = evaluator
      end

      def_delegators :@inner, :open, :close, :size, :rewind

      def next_item
        t = @inner.next_element
        return nil unless t
        @renamings.collect do |r|
          evaluator.evaluate( r.expression, TupleState.new( t ) )
        end
      end

    end

  end

end
